import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_photo.freezed.dart';
part 'device_photo.g.dart';

@freezed
abstract class DevicePhoto with _$DevicePhoto {
  const factory DevicePhoto({
    required String mediaId,
    required String path,
    required int width,
    required int height,
    required int sizeBytes,
    String? displayName,
    String? album,
    String? mimeType,
    DateTime? createDate,
    DateTime? modifiedDate,
    double? latitude,
    double? longitude,
  }) = _DevicePhoto;

  factory DevicePhoto.fromJson(Map<String, dynamic> json) =>
      _$DevicePhotoFromJson(json);
}
