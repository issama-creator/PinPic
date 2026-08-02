import 'package:photo_manager/photo_manager.dart';
import 'package:pinpic/core/errors/exceptions.dart';
import 'package:pinpic/shared/models/device_photo.dart';

class PhotoMediaService {
  Future<int> countDevicePhotos() async {
    try {
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );
      if (albums.isEmpty) return 0;
      return albums.first.assetCountAsync;
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
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isEmpty) return const [];

      final album = albums.first;
      final assets = await album.getAssetListPaged(
        page: page,
        size: pageSize,
      );

      final photos = <DevicePhoto>[];
      for (final asset in assets) {
        final file = await asset.originFile;
        if (file == null) continue;

        final latLng = await asset.latlngAsync();

        photos.add(
          DevicePhoto(
            mediaId: asset.id,
            path: file.path,
            width: asset.width,
            height: asset.height,
            sizeBytes: await file.length(),
            displayName: asset.title,
            album: album.name,
            mimeType: asset.mimeType,
            createDate: asset.createDateTime,
            modifiedDate: asset.modifiedDateTime,
            latitude: latLng?.latitude,
            longitude: latLng?.longitude,
          ),
        );
      }

      return photos;
    } catch (error) {
      throw MediaException(
        'Failed to fetch device photos: $error',
        code: 'media_fetch_failed',
      );
    }
  }

  Future<List<AssetEntity>> fetchAssetPage({
    int page = 0,
    int pageSize = 100,
  }) async {
    final albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );
    if (albums.isEmpty) return const [];
    return albums.first.getAssetListPaged(page: page, size: pageSize);
  }

  Future<AssetEntity?> findAssetById(String mediaId) {
    return AssetEntity.fromId(mediaId);
  }
}
