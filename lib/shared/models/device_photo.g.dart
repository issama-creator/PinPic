// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DevicePhoto _$DevicePhotoFromJson(Map<String, dynamic> json) => _DevicePhoto(
  mediaId: json['mediaId'] as String,
  path: json['path'] as String,
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  sizeBytes: (json['sizeBytes'] as num).toInt(),
  displayName: json['displayName'] as String?,
  album: json['album'] as String?,
  mimeType: json['mimeType'] as String?,
  createDate: json['createDate'] == null
      ? null
      : DateTime.parse(json['createDate'] as String),
  modifiedDate: json['modifiedDate'] == null
      ? null
      : DateTime.parse(json['modifiedDate'] as String),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$DevicePhotoToJson(_DevicePhoto instance) =>
    <String, dynamic>{
      'mediaId': instance.mediaId,
      'path': instance.path,
      'width': instance.width,
      'height': instance.height,
      'sizeBytes': instance.sizeBytes,
      'displayName': instance.displayName,
      'album': instance.album,
      'mimeType': instance.mimeType,
      'createDate': instance.createDate?.toIso8601String(),
      'modifiedDate': instance.modifiedDate?.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
