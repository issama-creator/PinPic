import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/database_service.dart';
import 'package:pinpic/services/face_service.dart';
import 'package:pinpic/services/indexing_service.dart';
import 'package:pinpic/services/ocr_service.dart';
import 'package:pinpic/services/photo_media_service.dart';
import 'package:pinpic/services/qr_service.dart';
import 'package:pinpic/services/vision_service.dart';
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
}) {
  return IndexingService(
    mediaService: media,
    photoRepository: photos,
    settingsRepository: _FakeSettings(),
    ocrService: ocr ?? _FakeOcr(),
    qrService: _FakeQr(),
    visionService: _FakeVision(),
    faceService: _FakeFace(),
    categoryEngine: CategoryEngine(),
  );
}

DevicePhoto _device(String id, {int modifiedMinute = 1}) {
  return DevicePhoto(
    mediaId: id,
    path: '/$id.jpg',
    width: 100,
    height: 200,
    sizeBytes: 1000,
    displayName: '$id.jpg',
    mimeType: 'image/jpeg',
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
  _FakeMedia(this.photos);

  final List<DevicePhoto> photos;

  @override
  Future<int> countDevicePhotos() async => photos.length;

  @override
  Future<List<DevicePhoto>> fetchDevicePhotos({
    int page = 0,
    int pageSize = 100,
  }) async {
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

  @override
  Future<AppSettingsEntity> updateIndexStats({
    required int totalPhotosFound,
    required int totalIndexed,
    required int totalCategories,
    bool initialScanCompleted = false,
  }) async {
    final settings = AppSettingsEntity.initial()
      ..totalPhotosFound = totalPhotosFound
      ..totalIndexed = totalIndexed
      ..totalCategories = totalCategories
      ..initialScanCompleted = initialScanCompleted;
    return settings;
  }
}

class _FakeOcr extends OcrService {
  _FakeOcr({this.corruptPath, this.delay = Duration.zero});

  final String? corruptPath;
  final Duration delay;
  int calls = 0;

  @override
  Future<String?> extractText(String path) async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (path == corruptPath) throw StateError('damaged');
    return 'Документ $path';
  }

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

class _FakeVision extends VisionService {
  @override
  Future<List<String>> detectLabelsAndObjects(String path) async {
    return const ['Document'];
  }

  @override
  Future<void> dispose() async {}
}

class _FakeFace extends FaceService {
  @override
  Future<bool> hasFace(String path) async => false;

  @override
  Future<void> dispose() async {}
}
