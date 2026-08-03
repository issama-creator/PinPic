import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_summary_service.dart';
import 'package:pinpic/services/fast_image_prep.dart';
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
    void Function(List<PhotoEntity> photos)? onPhotosIndexed,
  }) : _media = mediaService,
       _photos = photoRepository,
       _settings = settingsRepository,
       _ocr = ocrService ?? OcrService(),
       _qr = qrService ?? QrService(),
       _categories = categoryEngine ?? CategoryEngine(),
       _keywords = keywordEngine ?? KeywordEngine(),
       _embeddings = embeddingService ?? LocalSemanticEmbeddingService(),
       _summaries = summaryService ?? DocumentSummaryService(),
       _onPhotosIndexed = onPhotosIndexed;

  final PhotoMediaService _media;
  final PhotoRepository _photos;
  final SettingsRepository _settings;
  final OcrService _ocr;
  final QrService _qr;
  final CategoryEngine _categories;
  final KeywordEngine _keywords;
  final LocalSemanticEmbeddingService _embeddings;
  final DocumentSummaryService _summaries;
  final void Function(List<PhotoEntity> photos)? _onPhotosIndexed;

  final _progressController = StreamController<IndexProgress>.broadcast();

  IndexProgress _progress = const IndexProgress();
  bool _running = false;
  bool _stopRequested = false;
  DateTime _lastProgressEvent = DateTime.fromMillisecondsSinceEpoch(0);

  Stream<IndexProgress> get progressStream => _progressController.stream;
  IndexProgress get progress => _progress;
  bool get isRunning => _running;

  static const _pageSize = 48;
  /// Matches OCR/QR recognizer pool size for true parallel ML Kit work.
  static const _fastConcurrency = 2;
  static const _prepConcurrency = 4;
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

      final knownCategories = <String>{};
      final initialStats = await Future.wait<Object>([
        _photos.countAll(),
        _photos.distinctCategories(),
      ]);
      knownCategories.addAll(initialStats[1] as List<String>);
      await _settings.updateIndexStats(
        totalPhotosFound: total,
        totalIndexed: initialStats[0] as int,
        totalCategories: knownCategories.length,
      );

      // Load PP-OCR models while the priority + fast passes walk the gallery.
      final deepWarmup = _ocr.warmupDeepOcr();

      var page = 0;
      var newlyIndexed = 0;
      var failedPhotos = 0;
      var batchesSinceStatsUpdate = 0;
      final deepTasks = <_DeepOcrTask>[];
      final deepQueuedIds = <String>{};
      var ranDeepPass = false;
      final fastStopwatch = Stopwatch()..start();

      // 1) Narrow first: screenshots / chats / recent — searchable ASAP.
      final priorityStopwatch = Stopwatch()..start();
      final priorityPhotos = await _media.fetchPriorityPhotos();
      final priorityIds = <String>{
        for (final photo in priorityPhotos) photo.mediaId,
      };
      if (priorityPhotos.isNotEmpty && !_stopRequested) {
        _emit(
          IndexProgress(
            processed: 0,
            total: total,
            isRunning: true,
            isCompleted: false,
            status: IndexingStatus.running,
            stage: IndexingStage.fast,
            currentFileName: 'Сначала важное',
          ),
        );
        for (var i = 0; i < priorityPhotos.length && !_stopRequested; i += _pageSize) {
          final end = math.min(i + _pageSize, priorityPhotos.length);
          final batch = priorityPhotos.sublist(i, end);
          deviceMediaIds.addAll(batch.map((photo) => photo.mediaId));
          final batchResult = await _indexPhotoBatch(
            batch,
            total: total,
            forceFull: forceFull,
            knownCategories: knownCategories,
            deepTasks: deepTasks,
            deepQueuedIds: deepQueuedIds,
          );
          newlyIndexed += batchResult.newlyIndexed;
          failedPhotos += batchResult.failed;
        }
        priorityStopwatch.stop();
        if (kDebugMode) {
          debugPrint(
            'Index priority pass: ${priorityPhotos.length} photos in '
            '${priorityStopwatch.elapsedMilliseconds}ms',
          );
        }
        // Memory is already useful — refresh stats / sample hint before the rest.
        final indexedAfterPriority = await _photos.countAll();
        await _settings.updateIndexStats(
          totalPhotosFound: total,
          totalIndexed: indexedAfterPriority,
          totalCategories: knownCategories.length,
        );
        _emit(
          IndexProgress(
            processed: _progress.processed.clamp(0, total),
            total: total,
            isRunning: true,
            isCompleted: false,
            status: IndexingStatus.running,
            stage: IndexingStage.fast,
            currentFileName: 'Уже можно искать',
          ),
        );
      }

      // 2) Rest of the gallery (skip ids already handled in the priority pass).
      Future<List<DevicePhoto>>? nextBatchFuture = _media.fetchDevicePhotos(
        page: 0,
        pageSize: _pageSize,
      );

      while (!_stopRequested) {
        final batch = await (nextBatchFuture ??
            _media.fetchDevicePhotos(page: page, pageSize: _pageSize));
        if (batch.isEmpty) break;

        // Prefetch the next page while this batch is processed.
        nextBatchFuture = _media.fetchDevicePhotos(
          page: page + 1,
          pageSize: _pageSize,
        );

        deviceMediaIds.addAll(batch.map((photo) => photo.mediaId));
        final remaining = priorityIds.isEmpty
            ? batch
            : batch
                .where((photo) => !priorityIds.contains(photo.mediaId))
                .toList(growable: false);
        if (remaining.isNotEmpty) {
          final batchResult = await _indexPhotoBatch(
            remaining,
            total: total,
            forceFull: forceFull,
            knownCategories: knownCategories,
            deepTasks: deepTasks,
            deepQueuedIds: deepQueuedIds,
          );
          newlyIndexed += batchResult.newlyIndexed;
          failedPhotos += batchResult.failed;
        }

        batchesSinceStatsUpdate++;
        if (batchesSinceStatsUpdate >= 3) {
          await _updateStatsLight(total, knownCategories.length);
          batchesSinceStatsUpdate = 0;
        }

        if (batch.length < _pageSize) break;
        page++;
      }

      fastStopwatch.stop();
      if (kDebugMode) {
        debugPrint(
          'Index fast pass: $newlyIndexed photos in '
          '${fastStopwatch.elapsedMilliseconds}ms; deep OCR queued: ${deepTasks.length}',
        );
      }

      // Resume any deep backlog left from a previous interrupted pass.
      if (!_stopRequested) {
        final pendingDeep = await _photos.findNeedingDeepOcr();
        for (final photo in pendingDeep) {
          if (!deepQueuedIds.add(photo.mediaId)) continue;
          deepTasks.add(
            _DeepOcrTask.fromFields(
              mediaId: photo.mediaId,
              path: photo.path,
              displayName: photo.displayName,
            ),
          );
        }
      }

      // Memory is searchable after the fast pass — mark ready before deep OCR.
      final indexedAfterFast = await _photos.countAll();
      if (!_stopRequested) {
        await _settings.updateIndexStats(
          totalPhotosFound: total,
          totalIndexed: indexedAfterFast,
          totalCategories: knownCategories.length,
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

      if (!_stopRequested) {
        await _photos.deleteMissingMediaIds(deviceMediaIds);
      }

      if (!_stopRequested && deepTasks.isNotEmpty) {
        ranDeepPass = true;
        await deepWarmup;
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
      final finalStats = await Future.wait<Object>([
        _photos.countAll(),
        _photos.distinctCategories(),
      ]);
      final indexed = finalStats[0] as int;
      final categories = finalStats[1] as List<String>;
      await _settings.updateIndexStats(
        totalPhotosFound: total,
        totalIndexed: indexed,
        totalCategories: categories.length,
        initialScanCompleted: !_stopRequested,
        indexedPipelineVersion: HashUtils.indexPipelineVersion,
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

  Future<({int newlyIndexed, int failed})> _indexPhotoBatch(
    List<DevicePhoto> batch, {
    required int total,
    required bool forceFull,
    required Set<String> knownCategories,
    required List<_DeepOcrTask> deepTasks,
    required Set<String> deepQueuedIds,
  }) async {
    if (batch.isEmpty) return (newlyIndexed: 0, failed: 0);

    final existingById = forceFull
        ? const <String, PhotoEntity>{}
        : await _photos.getByMediaIds(batch.map((photo) => photo.mediaId));
    final toUpsert = <PhotoEntity>[];
    final work = <DevicePhoto>[];
    var newlyIndexed = 0;
    var failedPhotos = 0;

    for (final device in batch) {
      if (_stopRequested) break;

      final hash = HashUtils.photoFingerprint(
        mediaId: device.mediaId,
        width: device.width,
        height: device.height,
        sizeBytes: device.sizeBytes,
        modifiedAt: device.modifiedDate,
      );

      final existing = existingById[device.mediaId];
      if (!forceFull && existing?.hash == hash) {
        final category = existing?.category;
        if (category != null && category.isNotEmpty) {
          knownCategories.add(category);
        }
        if (existing?.needsDeepOcr == true &&
            deepQueuedIds.add(device.mediaId)) {
          deepTasks.add(_DeepOcrTask(device));
        }
        _emitProgress(
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
        _emitProgress(
          _progress.copyWith(
            processed: (_progress.processed + 1).clamp(0, total),
            currentFileName: device.displayName ?? device.mediaId,
          ),
        );
        continue;
      }

      work.add(device);
    }

    final preparedById = <String, String?>{};
    await _forEachConcurrent(work, _prepConcurrency, (device) async {
      if (_stopRequested) return;
      preparedById[device.mediaId] = await FastImagePrep.prepare(
        mediaId: device.mediaId,
        path: device.path,
        width: device.width,
        height: device.height,
      );
    });

    await _forEachConcurrent(work, _fastConcurrency, (device) async {
      if (_stopRequested) return;

      _emitProgress(
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
      final prepared = preparedById[device.mediaId];

      try {
        final inputPath = prepared ?? device.path;
        late final String? ocrText;
        late final QrScanResult qr;
        try {
          final results = await Future.wait<Object?>([
            _ocr.extractFastText(device.path, preparedPath: inputPath),
            _qr.scan(inputPath),
          ]);
          ocrText = results[0] as String?;
          qr = results[1] as QrScanResult;
        } finally {
          await FastImagePrep.disposePrepared(prepared);
        }

        var resolvedQr = qr;
        if (prepared != null &&
            !qr.hasQr &&
            _needsFullQrRetry(
              ocrText,
              mimeType: device.mimeType,
              displayName: device.displayName,
            )) {
          resolvedQr = await _qr.scan(device.path);
        }

        const objects = <String>[];
        final category = _categories.classify(
          ocrText: ocrText,
          objects: objects,
          hasQr: resolvedQr.hasQr,
          displayName: device.displayName,
          mimeType: device.mimeType,
        );
        if (category != null) knownCategories.add(category);
        final summaryEntities = _summaries.extract(
          ocrText: ocrText,
          category: category,
          dateTaken: device.createDate,
          qrPayload: resolvedQr.payload,
        );
        final entityTokens = summaryEntities.searchTokens;
        final keywords = [
          ..._keywords.build(
            ocrText: ocrText,
            objects: objects,
            category: category,
            displayName: device.displayName,
            album: device.album,
            qrPayload: resolvedQr.payload,
            hasQr: resolvedQr.hasQr,
          ),
          ...entityTokens,
        ];
        final ocrKeywords = _capTerms(_keywords.tokenize(ocrText));
        final semanticEmbedding = _embeddings.forPhoto(
          ocrTerms: ocrKeywords,
          visionTerms: const [],
          categoryTerms: [if (category != null) category],
          hasQr: resolvedQr.hasQr,
        );

        final wantsDeep = _shouldRunDeepOcr(
          ocrText,
          category: category,
          mimeType: device.mimeType,
          hasQr: resolvedQr.hasQr,
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
          hasQr: resolvedQr.hasQr,
          hasFace: false,
          needsDeepOcr: wantsDeep,
          qrPayload: resolvedQr.payload,
          modifiedAt: device.modifiedDate,
        );
        _summaries.applyToPhoto(
          entity,
          summaryEntities,
          fallbackTitle: category,
        );
        toUpsert.add(entity);
        newlyIndexed++;
        if (wantsDeep && deepQueuedIds.add(device.mediaId)) {
          deepTasks.add(_DeepOcrTask(device));
        }
      } catch (error, stack) {
        failedPhotos++;
        debugPrint('Failed to index ${device.mediaId}: $error\n$stack');
      }

      _emitProgress(
        _progress.copyWith(
          processed: (_progress.processed + 1).clamp(0, total),
          currentFileName: device.displayName ?? device.mediaId,
        ),
      );
    });

    if (toUpsert.isNotEmpty) {
      await _photos.upsertAll(toUpsert);
      _onPhotosIndexed?.call(List<PhotoEntity>.from(toUpsert));
    }
    return (newlyIndexed: newlyIndexed, failed: failedPhotos);
  }

  void stop() {
    _stopRequested = true;
  }

  List<String> _capTerms(List<String> terms) {
    if (terms.length <= _maxIndexedSignalTerms) return terms;
    return terms.take(_maxIndexedSignalTerms).toList(growable: false);
  }

  bool _needsFullQrRetry(
    String? fastText, {
    String? mimeType,
    String? displayName,
  }) {
    final mime = mimeType?.toLowerCase() ?? '';
    if (mime.contains('png')) return true;
    final clue = '${displayName ?? ''} ${fastText ?? ''}'.toLowerCase();
    return RegExp(
      r'\bqr\b|qr.?код|scan\s*me|сканир|barcode|штрихкод',
      caseSensitive: false,
    ).hasMatch(clue);
  }

  /// Deep OCR for real documents / screenshots — not for bare QR codes.
  /// Ordinary scenic photos with random ML Kit noise stay on the fast path.
  bool _shouldRunDeepOcr(
    String? fastText, {
    String? category,
    String? mimeType,
    bool hasQr = false,
  }) {
    // Pure QR bitmaps rarely need Cyrillic PP-OCR; skip the expensive pass.
    if (hasQr &&
        (category == null ||
            category == CategoryEngine.qr ||
            (fastText?.trim().isEmpty ?? true))) {
      return false;
    }
    if (category != null &&
        CategoryEngine.documentFamily.contains(category) &&
        category != CategoryEngine.qr) {
      return true;
    }
    final mime = mimeType?.toLowerCase() ?? '';
    if (mime.contains('png') && _ocr.needsDeepText(fastText)) {
      return true;
    }
    final fast = fastText?.trim() ?? '';
    if (fast.isEmpty) return false;
    if (hasQr) return false;
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
    for (var offset = 0; offset < tasks.length && !_stopRequested;) {
      final end = math.min(offset + _pageSize, tasks.length);
      final chunk = tasks.sublist(offset, end);
      final existingById = await _photos.getByMediaIds(
        chunk.map((task) => task.mediaId),
      );

      for (var i = 0; i < chunk.length && !_stopRequested; i++) {
        final task = chunk[i];
        final index = offset + i;
        try {
          final existing = existingById[task.mediaId];
          if (existing != null) {
            final deepText = await _ocr.extractDeepText(
              task.path,
              // Native OCR retries rotation/contrast only when the first result
              // is weak, so normal documents stay fast without losing recovery.
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
                ..indexedAt = DateTime.now()
                ..needsDeepOcr = false;
              _summaries.applyToPhoto(
                existing,
                entities,
                fallbackTitle: category,
              );
              pending.add(existing);
            } else if (existing.needsDeepOcr) {
              // Deep pass finished with no richer text — clear backlog flag.
              existing.needsDeepOcr = false;
              pending.add(existing);
            }
          }
        } catch (error, stack) {
          debugPrint('Deep OCR failed for ${task.mediaId}: $error\n$stack');
        }

        if (pending.length >= _pageSize) {
          await _photos.upsertAll(pending);
          _onPhotosIndexed?.call(List<PhotoEntity>.from(pending));
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
      offset = end;
    }
    if (pending.isNotEmpty) {
      await _photos.upsertAll(pending);
      _onPhotosIndexed?.call(List<PhotoEntity>.from(pending));
    }
  }

  Future<void> _forEachConcurrent<T>(
    List<T> items,
    int concurrency,
    Future<void> Function(T item) action,
  ) async {
    if (items.isEmpty) return;
    final workers = concurrency.clamp(1, items.length);
    var next = 0;
    Future<void> worker() async {
      while (!_stopRequested) {
        final index = next;
        next += 1;
        if (index >= items.length) return;
        await action(items[index]);
      }
    }

    await Future.wait(List.generate(workers, (_) => worker()));
  }

  /// Mid-scan stats without scanning all category values in Isar.
  Future<void> _updateStatsLight(int total, int knownCategoryCount) async {
    final indexed = await _photos.countAll();
    await _settings.updateIndexStats(
      totalPhotosFound: total,
      totalIndexed: indexed,
      totalCategories: knownCategoryCount,
    );
  }

  void _emit(IndexProgress value) {
    _progress = value;
    _lastProgressEvent = DateTime.now();
    if (!_progressController.isClosed) {
      _progressController.add(value);
    }
  }

  /// Keep counters exact while avoiding a full home-screen rebuild for every
  /// single gallery item on large libraries.
  void _emitProgress(IndexProgress value) {
    _progress = value;
    final now = DateTime.now();
    final shouldNotify =
        value.processed >= value.total ||
        now.difference(_lastProgressEvent) >= const Duration(milliseconds: 80);
    if (shouldNotify && !_progressController.isClosed) {
      _lastProgressEvent = now;
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

  _DeepOcrTask.fromFields({
    required this.mediaId,
    required this.path,
    this.displayName,
  });

  final String mediaId;
  final String path;
  final String? displayName;
}
