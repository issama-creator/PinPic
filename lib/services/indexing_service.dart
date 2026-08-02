import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/face_service.dart';
import 'package:pinpic/services/keyword_engine.dart';
import 'package:pinpic/services/ocr_service.dart';
import 'package:pinpic/services/photo_media_service.dart';
import 'package:pinpic/services/qr_service.dart';
import 'package:pinpic/services/vision_service.dart';
import 'package:pinpic/shared/models/index_progress.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';
import 'package:pinpic/shared/repositories/settings_repository.dart';

class IndexingService {
  IndexingService({
    required PhotoMediaService mediaService,
    required PhotoRepository photoRepository,
    required SettingsRepository settingsRepository,
    OcrService? ocrService,
    QrService? qrService,
    VisionService? visionService,
    FaceService? faceService,
    CategoryEngine? categoryEngine,
    KeywordEngine? keywordEngine,
  }) : _media = mediaService,
       _photos = photoRepository,
       _settings = settingsRepository,
       _ocr = ocrService ?? OcrService(),
       _qr = qrService ?? QrService(),
       _vision = visionService ?? VisionService(),
       _faces = faceService ?? FaceService(),
       _categories = categoryEngine ?? CategoryEngine(),
       _keywords = keywordEngine ?? KeywordEngine();

  final PhotoMediaService _media;
  final PhotoRepository _photos;
  final SettingsRepository _settings;
  final OcrService _ocr;
  final QrService _qr;
  final VisionService _vision;
  final FaceService _faces;
  final CategoryEngine _categories;
  final KeywordEngine _keywords;

  final _progressController = StreamController<IndexProgress>.broadcast();

  IndexProgress _progress = const IndexProgress();
  bool _running = false;
  bool _stopRequested = false;

  Stream<IndexProgress> get progressStream => _progressController.stream;
  IndexProgress get progress => _progress;
  bool get isRunning => _running;

  static const _pageSize = 24;

  /// Raster formats that Android's `BitmapFactory` (used internally by both
  /// ML Kit's `InputImage.fromFilePath` and Tesseract4Android's
  /// `TessBaseAPI.setImage`) can actually decode. Anything else — most
  /// notably `image/svg+xml`, which photo_manager's `RequestType.image`
  /// filter happily includes even though it's a vector format, not a
  /// bitmap — must never reach those native calls: Tesseract's plugin has
  /// no try/catch around its decode step and a failed decode there throws
  /// an uncaught exception on a raw Java `Thread`, which crashes the whole
  /// app process (not just the indexing isolate/future).
  static const _decodableMimeTypes = {
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
    'image/heic',
    'image/heif',
    'image/gif',
    'image/bmp',
  };

  bool _isDecodableRaster(String? mimeType, String path) {
    final mime = mimeType?.toLowerCase().trim();
    if (mime != null && mime.isNotEmpty) {
      return _decodableMimeTypes.contains(mime);
    }
    final lowerPath = path.toLowerCase();
    return _decodableMimeTypes.any(
      (type) => lowerPath.endsWith('.${type.split('/').last}'),
    );
  }

  Future<void> start({bool forceFull = false}) async {
    if (_running) return;
    _running = true;
    _stopRequested = false;

    try {
      final total = await _media.countDevicePhotos();
      final deviceMediaIds = <String>{};

      _emit(
        IndexProgress(
          processed: 0,
          total: total,
          isRunning: true,
          isCompleted: false,
          status: IndexingStatus.running,
        ),
      );

      await _settings.updateIndexStats(
        totalPhotosFound: total,
        totalIndexed: await _photos.countAll(),
        totalCategories: (await _photos.distinctCategories()).length,
      );

      var page = 0;
      var newlyIndexed = 0;
      var failedPhotos = 0;
      var batchesSinceStatsUpdate = 0;

      while (!_stopRequested) {
        final batch = await _media.fetchDevicePhotos(
          page: page,
          pageSize: _pageSize,
        );
        if (batch.isEmpty) break;

        deviceMediaIds.addAll(batch.map((photo) => photo.mediaId));
        final existingById = forceFull
            ? const <String, PhotoEntity>{}
            : await _photos.getByMediaIds(batch.map((photo) => photo.mediaId));
        final toUpsert = <PhotoEntity>[];

        for (final device in batch) {
          if (_stopRequested) break;

          _emit(
            _progress.copyWith(
              currentFileName: device.displayName ?? device.mediaId,
              isRunning: true,
              status: IndexingStatus.running,
            ),
          );

          final hash = HashUtils.photoFingerprint(
            mediaId: device.mediaId,
            width: device.width,
            height: device.height,
            sizeBytes: device.sizeBytes,
            modifiedAt: device.modifiedDate,
          );

          final existing = existingById[device.mediaId];
          if (!forceFull && existing?.hash == hash) {
            _emit(
              _progress.copyWith(
                processed: (_progress.processed + 1).clamp(0, total),
              ),
            );
            continue;
          }

          if (!_isDecodableRaster(device.mimeType, device.path)) {
            failedPhotos++;
            debugPrint(
              'Skipping non-raster/undecodable file '
              '(mime=${device.mimeType}): ${device.path}',
            );
            _emit(
              _progress.copyWith(
                processed: (_progress.processed + 1).clamp(0, total),
                currentFileName: device.displayName ?? device.mediaId,
              ),
            );
            continue;
          }

          try {
            final ocrFuture = _ocr.extractText(device.path);
            final qrFuture = _qr.scan(device.path);
            final visionFuture = _vision.detectLabelsAndObjects(device.path);
            final faceFuture = _faces.hasFace(device.path);
            final ocrText = await ocrFuture;
            final qr = await qrFuture;
            final objects = await visionFuture;
            final hasFace = await faceFuture;
            final category = _categories.classify(
              ocrText: ocrText,
              objects: objects,
              hasQr: qr.hasQr,
              hasFace: hasFace,
              displayName: device.displayName,
              mimeType: device.mimeType,
            );
            final keywords = _keywords.build(
              ocrText: ocrText,
              objects: objects,
              category: category,
              displayName: device.displayName,
              qrPayload: qr.payload,
              hasQr: qr.hasQr,
              hasFace: hasFace,
            );

            toUpsert.add(
              PhotoEntity.create(
                mediaId: device.mediaId,
                path: device.path,
                hash: hash,
                width: device.width,
                height: device.height,
                sizeBytes: device.sizeBytes,
                indexedAt: DateTime.now(),
                displayName: device.displayName,
                ocrText: ocrText,
                objects: objects,
                category: category,
                keywords: keywords,
                dateTaken: device.createDate,
                latitude: device.latitude,
                longitude: device.longitude,
                album: device.album,
                mimeType: device.mimeType,
                isFavorite: existing?.isFavorite ?? false,
                hasQr: qr.hasQr,
                qrPayload: qr.payload,
                modifiedAt: device.modifiedDate,
              ),
            );
            newlyIndexed++;
          } catch (error, stack) {
            failedPhotos++;
            debugPrint('Failed to index ${device.mediaId}: $error\n$stack');
          }

          _emit(
            _progress.copyWith(
              processed: (_progress.processed + 1).clamp(0, total),
              currentFileName: device.displayName ?? device.mediaId,
            ),
          );
        }

        if (toUpsert.isNotEmpty) {
          await _photos.upsertAll(toUpsert);
        }

        batchesSinceStatsUpdate++;
        if (batchesSinceStatsUpdate >= 4) {
          await _updateStats(total);
          batchesSinceStatsUpdate = 0;
        }

        if (batch.length < _pageSize) break;
        page++;
      }

      if (!_stopRequested) {
        await _photos.deleteMissingMediaIds(deviceMediaIds);
      }
      final indexed = await _photos.countAll();
      final categories = await _photos.distinctCategories();
      await _settings.updateIndexStats(
        totalPhotosFound: total,
        totalIndexed: indexed,
        totalCategories: categories.length,
        initialScanCompleted: !_stopRequested,
      );

      _emit(
        IndexProgress(
          processed: _stopRequested ? _progress.processed : total,
          total: total,
          isRunning: false,
          isCompleted: !_stopRequested,
          status: _stopRequested
              ? IndexingStatus.paused
              : IndexingStatus.completed,
          currentFileName: newlyIndexed > 0
              ? 'Индексировано +$newlyIndexed'
              : null,
          errorMessage: failedPhotos > 0
              ? 'Не удалось обработать файлов: $failedPhotos'
              : null,
        ),
      );
    } catch (error, stack) {
      debugPrint('Indexing failed: $error\n$stack');
      _emit(
        _progress.copyWith(
          isRunning: false,
          isCompleted: false,
          status: IndexingStatus.failed,
          errorMessage: 'Индексация прервана. Попробуйте ещё раз.',
        ),
      );
    } finally {
      _running = false;
    }
  }

  void stop() {
    _stopRequested = true;
  }

  Future<void> _updateStats(int total) async {
    final indexed = await _photos.countAll();
    final categories = await _photos.distinctCategories();
    await _settings.updateIndexStats(
      totalPhotosFound: total,
      totalIndexed: indexed,
      totalCategories: categories.length,
    );
  }

  void _emit(IndexProgress value) {
    _progress = value;
    if (!_progressController.isClosed) {
      _progressController.add(value);
    }
  }

  Future<void> dispose() async {
    stop();
    await _ocr.dispose();
    await _qr.dispose();
    await _vision.dispose();
    await _faces.dispose();
    await _progressController.close();
  }
}
