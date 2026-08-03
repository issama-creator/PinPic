import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/database_service.dart';
import 'package:pinpic/services/indexing_service.dart';
import 'package:pinpic/services/ocr_service.dart';
import 'package:pinpic/services/photo_media_service.dart';
import 'package:pinpic/services/qr_service.dart';
import 'package:pinpic/shared/models/app_settings_entity.dart';
import 'package:pinpic/shared/models/device_photo.dart';
import 'package:pinpic/shared/models/index_progress.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';
import 'package:pinpic/shared/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('indexes new photos and removes deleted records', () async {
    final media = _FakeMedia([_device('new')]);
    final photos = _FakePhotos()
      ..items['deleted'] = _entity('deleted', hash: 'old');
    final service = _service(media: media, photos: photos);
    addTearDown(service.dispose);

    await service.start();

    expect(photos.items.keys, {'new'});
    expect(service.progress.status, IndexingStatus.completed);
    expect(service.progress.fraction, 1);
  });

  test('priority photos are indexed before the rest of the gallery', () async {
    final ocr = _FakeOcr();
    final media = _FakeMedia(
      [_device('old'), _device('shot', mimeType: 'image/png')],
      priorityIds: const ['shot'],
    );
    final photos = _FakePhotos();
    final service = _service(media: media, photos: photos, ocr: ocr);
    addTearDown(service.dispose);

    await service.start();

    expect(media.fetchOrder.first, 'priority');
    expect(media.fetchOrder, contains('all:0'));
    expect(photos.items.keys, {'old', 'shot'});
    expect(ocr.fastCalls, 2);
    expect(service.progress.status, IndexingStatus.completed);
  });

  test('skips unchanged fingerprint without running OCR', () async {
    final device = _device('same');
    final photos = _FakePhotos()
      ..items['same'] = _entity('same', hash: _hash(device));
    final ocr = _FakeOcr();
    final service = _service(
      media: _FakeMedia([device]),
      photos: photos,
      ocr: ocr,
    );
    addTearDown(service.dispose);

    await service.start();

    expect(ocr.calls, 0);
    expect(service.progress.status, IndexingStatus.completed);
  });

  test('reindexes changed photo and preserves favorite', () async {
    final device = _device('changed', modifiedMinute: 2);
    final photos = _FakePhotos()
      ..items['changed'] = (_entity('changed', hash: 'stale')
        ..isFavorite = true);
    final service = _service(media: _FakeMedia([device]), photos: photos);
    addTearDown(service.dispose);

    await service.start();

    expect(photos.items['changed']!.hash, _hash(device));
    expect(photos.items['changed']!.isFavorite, isTrue);
  });

  test('isolates a damaged photo and continues the batch', () async {
    final ocr = _FakeOcr(corruptPath: '/bad.jpg');
    final photos = _FakePhotos();
    final service = _service(
      media: _FakeMedia([_device('bad'), _device('good')]),
      photos: photos,
      ocr: ocr,
    );
    addTearDown(service.dispose);

    await service.start();

    expect(photos.items, contains('good'));
    expect(photos.items, isNot(contains('bad')));
    expect(service.progress.status, IndexingStatus.completed);
    expect(service.progress.errorMessage, contains('1'));
  });

  test(
    'runs deep OCR on screenshots when fast text is missing',
    () async {
      final ocr = _FakeOcr(fastResult: null, deepResult: 'Паспорт № 1234');
      final photos = _FakePhotos();
      final service = _service(
        media: _FakeMedia([
          _device(
            'deep',
            mimeType: 'image/png',
            album: 'Screenshots',
            displayName: 'Screenshot_1.png',
          ),
        ]),
        photos: photos,
        ocr: ocr,
      );
      addTearDown(service.dispose);

      await service.start();

      expect(ocr.fastCalls, 1);
      expect(ocr.deepCalls, 1);
      expect(photos.items['deep']!.ocrText, contains('Паспорт'));
      expect(service.progress.stage, IndexingStage.deep);
    },
  );

  test('skips OCR for likely scenic camera JPEGs on the rest pass', () async {
    final scenic = _device(
      'cam',
      displayName: 'IMG_1234.jpg',
      width: 4000,
      height: 3000,
    );
    final ocr = _FakeOcr();
    final photos = _FakePhotos();
    final service = _service(
      media: _FakeMedia([scenic]),
      photos: photos,
      ocr: ocr,
    );
    addTearDown(service.dispose);

    await service.start();

    expect(ocr.fastCalls, 0);
    expect(ocr.deepCalls, 0);
    expect(photos.items['cam'], isNotNull);
    expect(photos.items['cam']!.ocrText, isNull);
  });

  test('still OCRs scenic-looking photos in the priority pass', () async {
    final scenic = _device(
      'cam',
      displayName: 'IMG_1234.jpg',
      width: 4000,
      height: 3000,
    );
    final ocr = _FakeOcr();
    final service = _service(
      media: _FakeMedia([scenic], priorityIds: const ['cam']),
      photos: _FakePhotos(),
      ocr: ocr,
    );
    addTearDown(service.dispose);

    await service.start();

    expect(ocr.fastCalls, 1);
  });

  test('caps deep OCR per run and keeps the backlog', () async {
    final devices = List.generate(5, (index) => _device('deep-$index'));
    final photos = _FakePhotos();
    for (final device in devices) {
      photos.items[device.mediaId] = (_entity(device.mediaId, hash: _hash(device))
        ..needsDeepOcr = true
        ..ocrText = '156 456 123456'
        ..category = CategoryEngine.tickets);
    }
    final ocr = _FakeOcr(
      deepResult: 'БИЛЕТ НА КОНЦЕРТ',
      appendPath: false,
    );
    final service = _service(
      media: _FakeMedia(devices),
      photos: photos,
      ocr: ocr,
      maxDeepOcrPerRun: 2,
    );
    addTearDown(service.dispose);

    await service.start();

    expect(ocr.fastCalls, 0);
    expect(ocr.deepCalls, 2);
    expect(
      photos.items.values.where((photo) => photo.needsDeepOcr).length,
      3,
    );
  });

  test('runs deep OCR for a digit-only ticket fast result', () async {
    final ocr = _FakeOcr(
      fastResult: '156 456 123456',
      deepResult: 'БИЛЕТ НА КОНЦЕРТ',
      appendPath: false,
    );
    final photos = _FakePhotos();
    final service = _service(
      media: _FakeMedia([_device('ticket')]),
      photos: photos,
      ocr: ocr,
    );
    addTearDown(service.dispose);

    await service.start();

    final ticket = photos.items['ticket']!;
    expect(ocr.deepCalls, 1);
    expect(ticket.category, CategoryEngine.tickets);
    expect(ticket.keywords, containsAll(['билет', 'ticket']));
  });

  test('skips deep OCR for a textless non-document photo', () async {
    final ocr = _FakeOcr(fastResult: null, deepResult: 'не должно читаться');
    final service = _service(
      media: _FakeMedia([_device('landscape')]),
      photos: _FakePhotos(),
      ocr: ocr,
    );
    addTearDown(service.dispose);

    await service.start();

    expect(ocr.deepCalls, 0);
  });

  test('resumes persisted deep OCR backlog after interrupt', () async {
    final device = _device('resume');
    final photos = _FakePhotos()
      ..items['resume'] = (_entity('resume', hash: _hash(device))
        ..needsDeepOcr = true
        ..ocrText = '156 456');
    final ocr = _FakeOcr(
      fastResult: 'ignored',
      deepResult: 'БИЛЕТ НА КОНЦЕРТ',
      appendPath: false,
    );
    final service = _service(
      media: _FakeMedia([device]),
      photos: photos,
      ocr: ocr,
    );
    addTearDown(service.dispose);

    await service.start();

    expect(ocr.fastCalls, 0);
    expect(ocr.deepCalls, 1);
    expect(photos.items['resume']!.needsDeepOcr, isFalse);
    expect(photos.items['resume']!.ocrText, contains('БИЛЕТ'));
  });

  test('stop pauses without false 100 percent and resume completes', () async {
    final devices = List.generate(30, (index) => _device('photo-$index'));
    final photos = _FakePhotos();
    final service = _service(
      media: _FakeMedia(devices),
      photos: photos,
      ocr: _FakeOcr(delay: const Duration(milliseconds: 8)),
    );
    addTearDown(service.dispose);

    final firstRun = service.start();
    await Future<void>.delayed(const Duration(milliseconds: 25));
    service.stop();
    await firstRun;

    expect(service.progress.status, IndexingStatus.paused);
    expect(service.progress.processed, lessThan(service.progress.total));

    await service.start();
    expect(service.progress.status, IndexingStatus.completed);
    expect(service.progress.processed, service.progress.total);
    expect(photos.items.length, 30);
  });
}

IndexingService _service({
  required _FakeMedia media,
  required _FakePhotos photos,
  _FakeOcr? ocr,
  int maxDeepOcrPerRun = 96,
}) {
  return IndexingService(
    mediaService: media,
    photoRepository: photos,
    settingsRepository: _FakeSettings(),
    ocrService: ocr ?? _FakeOcr(),
    qrService: _FakeQr(),
    categoryEngine: CategoryEngine(),
    maxDeepOcrPerRun: maxDeepOcrPerRun,
  );
}

DevicePhoto _device(
  String id, {
  int modifiedMinute = 1,
  String mimeType = 'image/jpeg',
  String? displayName,
  String? album,
  int width = 100,
  int height = 200,
}) {
  return DevicePhoto(
    mediaId: id,
    path: '/$id.jpg',
    width: width,
    height: height,
    sizeBytes: 1000,
    displayName: displayName ?? '$id.jpg',
    album: album,
    mimeType: mimeType,
    createDate: DateTime(2026, 1, 1),
    modifiedDate: DateTime(2026, 1, 1, 0, modifiedMinute),
  );
}

String _hash(DevicePhoto photo) {
  return HashUtils.photoFingerprint(
    mediaId: photo.mediaId,
    width: photo.width,
    height: photo.height,
    sizeBytes: photo.sizeBytes,
    modifiedAt: photo.modifiedDate,
  );
}

PhotoEntity _entity(String id, {required String hash}) {
  return PhotoEntity.create(
    mediaId: id,
    path: '/$id.jpg',
    hash: hash,
    width: 100,
    height: 200,
    sizeBytes: 1000,
    indexedAt: DateTime(2026),
  );
}

class _FakeMedia extends PhotoMediaService {
  _FakeMedia(this.photos, {this.priorityIds = const []});

  final List<DevicePhoto> photos;
  final List<String> priorityIds;
  final List<String> fetchOrder = [];

  @override
  Future<int> countDevicePhotos() async => photos.length;

  @override
  Future<List<DevicePhoto>> fetchPriorityPhotos({
    int recentDays = PhotoMediaService.priorityRecentDays,
    int maxCount = PhotoMediaService.priorityMaxCount,
  }) async {
    fetchOrder.add('priority');
    if (priorityIds.isEmpty) return const [];
    final byId = {for (final photo in photos) photo.mediaId: photo};
    return [
      for (final id in priorityIds)
        if (byId[id] != null) byId[id]!,
    ].take(maxCount).toList(growable: false);
  }

  @override
  Future<List<DevicePhoto>> fetchDevicePhotos({
    int page = 0,
    int pageSize = 100,
  }) async {
    fetchOrder.add('all:$page');
    final start = page * pageSize;
    if (start >= photos.length) return const [];
    final end = (start + pageSize).clamp(0, photos.length);
    return photos.sublist(start, end);
  }
}

class _FakePhotos extends PhotoRepository {
  _FakePhotos() : super(DatabaseService());

  final Map<String, PhotoEntity> items = {};

  @override
  Future<int> countAll() async => items.length;

  @override
  Future<List<String>> distinctCategories() async => items.values
      .map((photo) => photo.category)
      .whereType<String>()
      .toSet()
      .toList();

  @override
  Future<Map<String, PhotoEntity>> getByMediaIds(
    Iterable<String> mediaIds,
  ) async {
    return {
      for (final id in mediaIds)
        if (items[id] != null) id: items[id]!,
    };
  }

  @override
  Future<PhotoEntity?> findByMediaId(String mediaId) async => items[mediaId];

  @override
  Future<List<PhotoEntity>> findNeedingDeepOcr({int limit = 500}) async {
    return items.values
        .where((photo) => photo.needsDeepOcr)
        .take(limit)
        .toList();
  }

  @override
  Future<void> upsertAll(List<PhotoEntity> photos) async {
    for (final photo in photos) {
      items[photo.mediaId] = photo;
    }
  }

  @override
  Future<int> deleteMissingMediaIds(Set<String> deviceMediaIds) async {
    final removed = items.keys
        .where((id) => !deviceMediaIds.contains(id))
        .toList();
    for (final id in removed) {
      items.remove(id);
    }
    return removed.length;
  }
}

class _FakeSettings extends SettingsRepository {
  _FakeSettings() : super(DatabaseService());

  final AppSettingsEntity current = AppSettingsEntity.initial();

  @override
  Future<AppSettingsEntity> getSettings() async => current;

  @override
  Future<AppSettingsEntity> update(
    void Function(AppSettingsEntity settings) mutate,
  ) async {
    mutate(current);
    return current;
  }

  @override
  Future<AppSettingsEntity> updateIndexStats({
    required int totalPhotosFound,
    required int totalIndexed,
    required int totalCategories,
    bool initialScanCompleted = false,
    int? indexedPipelineVersion,
  }) async {
    current
      ..totalPhotosFound = totalPhotosFound
      ..totalIndexed = totalIndexed
      ..totalCategories = totalCategories
      ..lastIndexedAt = DateTime.now();
    if (indexedPipelineVersion != null) {
      current.indexedPipelineVersion = indexedPipelineVersion;
    }
    if (initialScanCompleted) {
      current.initialScanCompleted = true;
    }
    return current;
  }
}

class _FakeOcr extends OcrService {
  _FakeOcr({
    this.corruptPath,
    this.delay = Duration.zero,
    this.fastResult = 'Документ',
    this.deepResult,
    this.appendPath = true,
  });

  final String? corruptPath;
  final Duration delay;
  final String? fastResult;
  final String? deepResult;
  final bool appendPath;
  int fastCalls = 0;
  int deepCalls = 0;
  int get calls => fastCalls;

  @override
  Future<String?> extractFastText(
    String path, {
    String? preparedPath,
  }) async {
    fastCalls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (path == corruptPath) throw StateError('damaged');
    if (fastResult == null) return null;
    return appendPath ? '$fastResult $path' : fastResult;
  }

  @override
  Future<String?> extractDeepText(
    String path, {
    bool aggressive = true,
  }) async {
    deepCalls++;
    return deepResult;
  }

  @override
  bool needsDeepText(String? fastText) {
    final text = fastText?.trim() ?? '';
    return text.isEmpty || RegExp(r'[a-zA-Z]').allMatches(text).length < 8;
  }

  @override
  Future<bool> warmupDeepOcr() async => true;

  @override
  Future<void> dispose() async {}
}

class _FakeQr extends QrService {
  @override
  Future<QrScanResult> scan(String path) async {
    return const QrScanResult(hasQr: false);
  }

  @override
  Future<void> dispose() async {}
}
