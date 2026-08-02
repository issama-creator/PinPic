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
      final photos = await Future.wait(
        assets.map((asset) => _toDevicePhoto(asset, album.name)),
      );
      return photos.whereType<DevicePhoto>().toList(growable: false);
    } catch (error) {
      throw MediaException(
        'Failed to fetch device photos: $error',
        code: 'media_fetch_failed',
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
    final fileFuture = asset.originFile;
    final locationFuture = asset.latlngAsync();
    final file = await fileFuture;
    if (file == null) return null;
    final results = await Future.wait([file.length(), locationFuture]);
    final latLng = results[1] as LatLng?;
    return DevicePhoto(
      mediaId: asset.id,
      path: file.path,
      width: asset.width,
      height: asset.height,
      sizeBytes: results.first as int,
      displayName: asset.title,
      album: album,
      mimeType: asset.mimeType,
      createDate: asset.createDateTime,
      modifiedDate: asset.modifiedDateTime,
      latitude: latLng?.latitude,
      longitude: latLng?.longitude,
    );
  }
}
