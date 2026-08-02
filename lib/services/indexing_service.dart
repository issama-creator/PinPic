import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_summary_service.dart';
import 'package:pinpic/services/keyword_engine.dart';
import 'package:pinpic/services/local_semantic_embedding_service.dart';
import 'package:pinpic/services/ocr_service.dart';
import 'package:pinpic/services/photo_media_service.dart';
import 'package:pinpic/services/qr_service.dart';
import 'package:pinpic/shared/models/device_photo.dart';
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
    CategoryEngine? categoryEngine,
    KeywordEngine? keywordEngine,
    LocalSemanticEmbeddingService? embeddingService,
    DocumentSummaryService? summaryService,
  }) : _media = mediaService,
       _photos = photoRepository,
       _settings = settingsRepository,
       _ocr = ocrService ?? OcrService(),
       _qr = qrService ?? QrService(),
       _categories = categoryEngine ?? CategoryEngine(),
       _keywords = keywordEngine ?? KeywordEngine(),
       _embeddings = embeddingService ?? LocalSemanticEmbeddingService(),
       _summaries = summaryService ?? DocumentSummaryService();

  final PhotoMediaService _media;
  final PhotoRepository _photos;
  final SettingsRepository _settings;
  final OcrService _ocr;
  final QrService _qr;
  final CategoryEngine _categories;
  final KeywordEngine _keywords;
  final LocalSemanticEmbeddingService _embeddings;
  final DocumentSummaryService _summaries;

  final _progressController = StreamController<IndexProgress>.broadcast();

  IndexProgress _progress = const IndexProgress();
  bool _running = false;
  bool _stopRequested = false;

  Stream<IndexProgress> get progressStream => _progressController.stream;
  IndexProgress get progress => _progress;
  bool get isRunning => _running;

  static const _pageSize = 24;
  static const _maxIndexedSignalTerms = 120;

  /// Raster formats that Android's `BitmapFactory` can decode.
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
      final deepTasks = <_DeepOcrTask>[];
      var ranDeepPass = false;
      final fastStopwatch = Stopwatch()..start();

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
            final ocrText = await _ocr.extractFastText(device.path);
            final qr = _shouldScanQr(
              ocrText,
              mimeType: device.mimeType,
              displayName: device.displayName,
            )
                ? await _qr.scan(device.path)
                : const QrScanResult(hasQr: false);
            const objects = <String>[];
            final category = _categories.classify(
              ocrText: ocrText,
              objects: objects,
              hasQr: qr.hasQr,
              displayName: device.displayName,
              mimeType: device.mimeType,
            );
            final summaryEntities = _summaries.extract(
              ocrText: ocrText,
              category: category,
              dateTaken: device.createDate,
              qrPayload: qr.payload,
            );
            final entityTokens = summaryEntities.searchTokens;
            final keywords = [
              ..._keywords.build(
                ocrText: ocrText,
                objects: objects,
                category: category,
                displayName: device.displayName,
                album: device.album,
                qrPayload: qr.payload,
                hasQr: qr.hasQr,
              ),
              ...entityTokens,
            ];
            final ocrKeywords = _capTerms(_keywords.tokenize(ocrText));
            final semanticEmbedding = _embeddings.forPhoto(
              ocrTerms: ocrKeywords,
              visionTerms: const [],
              categoryTerms: [if (category != null) category],
              hasQr: qr.hasQr,
            );

            final entity = PhotoEntity.create(
              mediaId: device.mediaId,
              path: device.path,
              hash: hash,
              width: device.width,
              height: device.height,
              sizeBytes: device.sizeBytes,
              indexedAt: DateTime.now(),
              displayName: device.displayName,
              ocrText: ocrText,
              summary: summaryEntities.summaryLine,
              ocrKeywords: ocrKeywords,
              objects: objects,
              visionKeywords: const [],
              category: category,
              keywords: _capTerms(keywords),
              semanticEmbedding: semanticEmbedding,
              dateTaken: device.createDate,
              latitude: device.latitude,
              longitude: device.longitude,
              album: device.album,
              mimeType: device.mimeType,
              isFavorite: existing?.isFavorite ?? false,
              isPinned: existing?.isPinned ?? false,
              hasQr: qr.hasQr,
              hasFace: false,
              qrPayload: qr.payload,
              modifiedAt: device.modifiedDate,
            );
            _summaries.applyToPhoto(
              entity,
              summaryEntities,
              fallbackTitle: category,
            );
            toUpsert.add(entity);
            newlyIndexed++;
            if (_shouldRunDeepOcr(
              ocrText,
              category: category,
              mimeType: device.mimeType,
              hasQr: qr.hasQr,
            )) {
              deepTasks.add(_DeepOcrTask(device));
            }
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
      fastStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          'Index fast pass: $newlyIndexed photos in '
          '${fastStopwatch.elapsedMilliseconds}ms; deep OCR queued: ${deepTasks.length}',
        );
      }

      // Memory is searchable after the fast pass — mark ready before deep OCR.
      final indexedAfterFast = await _photos.countAll();
      final categoriesAfterFast = await _photos.distinctCategories();
      if (!_stopRequested) {
        await _settings.updateIndexStats(
          totalPhotosFound: total,
          totalIndexed: indexedAfterFast,
          totalCategories: categoriesAfterFast.length,
          initialScanCompleted: true,
          indexedPipelineVersion: HashUtils.indexPipelineVersion,
        );
        _emit(
          IndexProgress(
            processed: total,
            total: total,
            isRunning: deepTasks.isNotEmpty,
            isCompleted: deepTasks.isEmpty,
            status: deepTasks.isEmpty
                ? IndexingStatus.completed
                : IndexingStatus.running,
            stage: deepTasks.isEmpty ? IndexingStage.fast : IndexingStage.deep,
            currentFileName: newlyIndexed > 0
                ? 'Индексировано +$newlyIndexed'
                : null,
            errorMessage: failedPhotos > 0
                ? 'Не удалось обработать файлов: $failedPhotos'
                : null,
          ),
        );
      }

      if (!_stopRequested && deepTasks.isNotEmpty) {
        ranDeepPass = true;
        final deepStopwatch = Stopwatch()..start();
        await _runDeepOcrPass(deepTasks);
        deepStopwatch.stop();
        if (kDebugMode) {
          debugPrint(
            'Index deep OCR: ${deepTasks.length} photos in '
            '${deepStopwatch.elapsedMilliseconds}ms',
          );
        }
      }
      final indexed = await _photos.countAll();
      final categories = await _photos.distinctCategories();
      await _settings.updateIndexStats(
        totalPhotosFound: total,
        totalIndexed: indexed,
        totalCategories: categories.length,
        initialScanCompleted: !_stopRequested,
        indexedPipelineVersion: _stopRequested
            ? null
            : HashUtils.indexPipelineVersion,
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
          stage: ranDeepPass ? IndexingStage.deep : IndexingStage.fast,
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

  List<String> _capTerms(List<String> terms) {
    if (terms.length <= _maxIndexedSignalTerms) return terms;
    return terms.take(_maxIndexedSignalTerms).toList(growable: false);
  }

  /// QR scan is almost as expensive as OCR. Skip it when fast OCR already
  /// captured a rich document, and only spend cycles when a code is likely.
  bool _shouldScanQr(
    String? ocrText, {
    String? mimeType,
    String? displayName,
  }) {
    final text = ocrText?.trim() ?? '';
    final mime = mimeType?.toLowerCase() ?? '';
    final name = (displayName ?? '').toLowerCase();

    if (text.isEmpty) return true;
    if (mime.contains('png')) return true;
    if (name.contains('screenshot') || name.contains('снимок')) return true;

    final lower = text.toLowerCase();
    if (RegExp(
      r'билет|boarding|ticket|qr|wifi|wi-fi|passbook|посадоч',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return true;
    }

    final digits = RegExp(r'\d').allMatches(text).length;
    // Rich receipt / contract OCR — QR rarely adds search value.
    if (text.length >= 100 && digits >= 6) return false;
    if (text.length >= 160) return false;
    // Thin OCR: a QR might be the only useful signal.
    return text.length < 48;
  }

  /// Deep OCR only for documents / screenshots / QR / document-looking text.
  /// Ordinary scenic photos with random ML Kit noise stay on the fast path.
  bool _shouldRunDeepOcr(
    String? fastText, {
    String? category,
    String? mimeType,
    bool hasQr = false,
  }) {
    if (category != null && CategoryEngine.documentFamily.contains(category)) {
      return true;
    }
    if (hasQr) return true;
    final mime = mimeType?.toLowerCase() ?? '';
    if (mime.contains('png') && _ocr.needsDeepText(fastText)) {
      return true;
    }
    final fast = fastText?.trim() ?? '';
    if (fast.isEmpty) return false;
    if (_looksDocumentish(fast)) return true;
    return false;
  }

  bool _looksDocumentish(String text) {
    final digits = RegExp(r'\d').allMatches(text).length;
    if (digits >= 8) return true;
    final lower = text.toLowerCase();
    return RegExp(
      r'₽|руб|rub|total|sum|итого|сумма|договор|гарант|паспорт|'
      r'passport|ticket|boarding|invoice|receipt|warranty|prescription|'
      r'wifi|password|login|билет|чек|визит|страхов',
      caseSensitive: false,
    ).hasMatch(lower);
  }

  Future<void> _runDeepOcrPass(List<_DeepOcrTask> tasks) async {
    _emit(
      IndexProgress(
        processed: 0,
        total: tasks.length,
        isRunning: true,
        isCompleted: true,
        status: IndexingStatus.running,
        stage: IndexingStage.deep,
        currentFileName: 'Уточняем текст',
      ),
    );

    final pending = <PhotoEntity>[];
    for (var index = 0; index < tasks.length && !_stopRequested; index++) {
      final task = tasks[index];
      try {
        final existing = await _photos.findByMediaId(task.mediaId);
        if (existing != null) {
          final deepText = await _ocr.extractDeepText(
            task.path,
            aggressive: true,
          );
          final mergedText = _ocr.pickRicherText(existing.ocrText, deepText);
          if (mergedText != null && mergedText != existing.ocrText) {
            final category = _categories.classify(
              ocrText: mergedText,
              objects: existing.objects,
              hasQr: existing.hasQr,
              displayName: existing.displayName,
              mimeType: existing.mimeType,
            );
            final ocrKeywords = _capTerms(_keywords.tokenize(mergedText));
            final entities = _summaries.extract(
              ocrText: mergedText,
              category: category,
              dateTaken: existing.dateTaken,
              qrPayload: existing.qrPayload,
            );
            existing
              ..ocrText = mergedText
              ..ocrKeywords = ocrKeywords
              ..category = category
              ..objects = const []
              ..visionKeywords = const []
              ..hasFace = false
              ..keywords = _capTerms([
                ..._keywords.build(
                  ocrText: mergedText,
                  objects: const [],
                  category: category,
                  displayName: existing.displayName,
                  album: existing.album,
                  qrPayload: existing.qrPayload,
                  hasQr: existing.hasQr,
                ),
                ...entities.searchTokens,
              ])
              ..semanticEmbedding = _embeddings.forPhoto(
                ocrTerms: ocrKeywords,
                visionTerms: const [],
                categoryTerms: [if (category != null) category],
                hasQr: existing.hasQr,
              )
              ..indexedAt = DateTime.now();
            _summaries.applyToPhoto(
              existing,
              entities,
              fallbackTitle: category,
            );
            pending.add(existing);
          }
        }
      } catch (error, stack) {
        debugPrint('Deep OCR failed for ${task.mediaId}: $error\n$stack');
      }

      if (pending.length >= _pageSize) {
        await _photos.upsertAll(pending);
        pending.clear();
      }
      _emit(
        _progress.copyWith(
          processed: index + 1,
          total: tasks.length,
          stage: IndexingStage.deep,
          currentFileName: task.displayName ?? task.mediaId,
        ),
      );
    }
    if (pending.isNotEmpty) {
      await _photos.upsertAll(pending);
    }
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
    await _progressController.close();
  }
}

class _DeepOcrTask {
  _DeepOcrTask(DevicePhoto photo)
    : mediaId = photo.mediaId,
      path = photo.path,
      displayName = photo.displayName;

  final String mediaId;
  final String path;
  final String? displayName;
}
