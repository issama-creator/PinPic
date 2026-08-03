import 'dart:math' as math;

import 'package:photo_manager/photo_manager.dart';
import 'package:pinpic/core/errors/exceptions.dart';
import 'package:pinpic/shared/models/device_photo.dart';

class PhotoMediaService {
  AssetPathEntity? _allAlbum;

  /// Cap so the first searchable window stays near ~30–60s on mid phones.
  static const priorityMaxCount = 140;
  static const priorityRecentDays = 14;
  static const _priorityPerAlbum = 80;

  Future<int> countDevicePhotos() async {
    try {
      final album = await _resolveAllAlbum();
      return album?.assetCountAsync ?? 0;
    } catch (error) {
      throw MediaException(
        'Failed to count device photos: $error',
        code: 'media_count_failed',
      );
    }
  }

  Future<List<DevicePhoto>> fetchDevicePhotos({
    int page = 0,
    int pageSize = 100,
  }) async {
    try {
      final album = await _resolveAllAlbum();
      if (album == null) return const [];
      final assets = await album.getAssetListPaged(page: page, size: pageSize);
      // Resolve files in parallel — gallery I/O is the usual startup bottleneck.
      final photos = await Future.wait(
        assets.map((asset) => _toDevicePhoto(asset, album.name)),
        eagerError: false,
      );
      return photos.whereType<DevicePhoto>().toList(growable: false);
    } catch (error) {
      throw MediaException(
        'Failed to fetch device photos: $error',
        code: 'media_fetch_failed',
      );
    }
  }

  /// High-yield first: screenshots / chats / downloads, then last [recentDays].
  ///
  /// This is the fast path to a successful find — not the full gallery.
  Future<List<DevicePhoto>> fetchPriorityPhotos({
    int recentDays = priorityRecentDays,
    int maxCount = priorityMaxCount,
  }) async {
    if (maxCount <= 0) return const [];
    try {
      final seen = <String>{};
      final out = <DevicePhoto>[];

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: false,
      );
      for (final album in albums) {
        if (out.length >= maxCount) break;
        if (album.isAll) continue;
        if (!_isPriorityAlbumName(album.name)) continue;
        await _appendAlbumPhotos(
          album: album,
          seen: seen,
          out: out,
          maxCount: maxCount,
          albumCap: _priorityPerAlbum,
        );
      }

      if (out.length < maxCount) {
        final now = DateTime.now();
        final recentFilter = FilterOptionGroup(
          createTimeCond: DateTimeCond(
            min: now.subtract(Duration(days: recentDays)),
            max: now.add(const Duration(days: 1)),
          ),
          orders: const [
            OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        );
        final recentAlbums = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
          filterOption: recentFilter,
        );
        if (recentAlbums.isNotEmpty) {
          await _appendAlbumPhotos(
            album: recentAlbums.first,
            seen: seen,
            out: out,
            maxCount: maxCount,
            albumCap: maxCount,
          );
        }
      }

      return List<DevicePhoto>.unmodifiable(out);
    } catch (error) {
      throw MediaException(
        'Failed to fetch priority photos: $error',
        code: 'media_priority_fetch_failed',
      );
    }
  }

  Future<List<DevicePhoto>> fetchByMediaIds(Iterable<String> mediaIds) async {
    final ids = mediaIds.where((id) => id.trim().isNotEmpty).toList();
    if (ids.isEmpty) return const [];
    try {
      final album = await _resolveAllAlbum();
      final albumName = album?.name ?? 'Gallery';
      final photos = await Future.wait(
        ids.map((id) async {
          final asset = await AssetEntity.fromId(id);
          if (asset == null || asset.type != AssetType.image) return null;
          return _toDevicePhoto(asset, albumName);
        }),
        eagerError: false,
      );
      return photos.whereType<DevicePhoto>().toList(growable: false);
    } catch (error) {
      throw MediaException(
        'Failed to fetch priority photos: $error',
        code: 'media_fetch_by_id_failed',
      );
    }
  }

  Future<AssetPathEntity?> _resolveAllAlbum() async {
    final cached = _allAlbum;
    if (cached != null) return cached;
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) return null;
    return _allAlbum = albums.first;
  }

  Future<void> _appendAlbumPhotos({
    required AssetPathEntity album,
    required Set<String> seen,
    required List<DevicePhoto> out,
    required int maxCount,
    required int albumCap,
  }) async {
    var page = 0;
    const pageSize = 40;
    var takenFromAlbum = 0;
    while (out.length < maxCount && takenFromAlbum < albumCap) {
      final take = math.min(
        pageSize,
        math.min(albumCap - takenFromAlbum, maxCount - out.length),
      );
      if (take <= 0) break;
      final assets = await album.getAssetListPaged(page: page, size: take);
      if (assets.isEmpty) break;

      final photos = await Future.wait(
        assets.map((asset) async {
          if (asset.type != AssetType.image) return null;
          if (!seen.add(asset.id)) return null;
          return _toDevicePhoto(asset, album.name);
        }),
        eagerError: false,
      );
      for (final photo in photos.whereType<DevicePhoto>()) {
        out.add(photo);
        takenFromAlbum++;
        if (out.length >= maxCount || takenFromAlbum >= albumCap) break;
      }
      if (assets.length < take) break;
      page++;
    }
  }

  static bool _isPriorityAlbumName(String raw) {
    final name = raw.toLowerCase().trim();
    if (name.isEmpty) return false;
    const needles = <String>[
      'screenshot',
      'screenshots',
      'screen shot',
      'скриншот',
      'скриншоты',
      'скрин',
      'whatsapp',
      'telegram',
      'viber',
      'signal',
      'download',
      'downloads',
      'загруз',
      'document',
      'documents',
      'документ',
    ];
    for (final needle in needles) {
      if (name.contains(needle)) return true;
    }
    return false;
  }

  Future<DevicePhoto?> _toDevicePhoto(AssetEntity asset, String album) async {
    // Prefer the display file (often already a decode-friendly JPEG). Fall
    // back to the original only when needed — originFile is much slower.
    final file = await asset.file ?? await asset.originFile;
    if (file == null) return null;
    final sizeBytes = await file.length();
    return DevicePhoto(
      mediaId: asset.id,
      path: file.path,
      width: asset.width,
      height: asset.height,
      sizeBytes: sizeBytes,
      displayName: asset.title,
      album: album,
      mimeType: asset.mimeType,
      createDate: asset.createDateTime,
      modifiedDate: asset.modifiedDateTime,
      latitude: null,
      longitude: null,
    );
  }
}
