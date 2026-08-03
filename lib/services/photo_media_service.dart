import 'package:photo_manager/photo_manager.dart';
import 'package:pinpic/core/errors/exceptions.dart';
import 'package:pinpic/shared/models/device_photo.dart';

class PhotoMediaService {
  AssetPathEntity? _allAlbum;

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
