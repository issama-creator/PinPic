// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_photo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DevicePhoto {

 String get mediaId; String get path; int get width; int get height; int get sizeBytes; String? get displayName; String? get album; String? get mimeType; DateTime? get createDate; DateTime? get modifiedDate; double? get latitude; double? get longitude;
/// Create a copy of DevicePhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DevicePhotoCopyWith<DevicePhoto> get copyWith => _$DevicePhotoCopyWithImpl<DevicePhoto>(this as DevicePhoto, _$identity);

  /// Serializes this DevicePhoto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DevicePhoto&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.path, path) || other.path == path)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.album, album) || other.album == album)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.createDate, createDate) || other.createDate == createDate)&&(identical(other.modifiedDate, modifiedDate) || other.modifiedDate == modifiedDate)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,path,width,height,sizeBytes,displayName,album,mimeType,createDate,modifiedDate,latitude,longitude);

@override
String toString() {
  return 'DevicePhoto(mediaId: $mediaId, path: $path, width: $width, height: $height, sizeBytes: $sizeBytes, displayName: $displayName, album: $album, mimeType: $mimeType, createDate: $createDate, modifiedDate: $modifiedDate, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $DevicePhotoCopyWith<$Res>  {
  factory $DevicePhotoCopyWith(DevicePhoto value, $Res Function(DevicePhoto) _then) = _$DevicePhotoCopyWithImpl;
@useResult
$Res call({
 String mediaId, String path, int width, int height, int sizeBytes, String? displayName, String? album, String? mimeType, DateTime? createDate, DateTime? modifiedDate, double? latitude, double? longitude
});




}
/// @nodoc
class _$DevicePhotoCopyWithImpl<$Res>
    implements $DevicePhotoCopyWith<$Res> {
  _$DevicePhotoCopyWithImpl(this._self, this._then);

  final DevicePhoto _self;
  final $Res Function(DevicePhoto) _then;

/// Create a copy of DevicePhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mediaId = null,Object? path = null,Object? width = null,Object? height = null,Object? sizeBytes = null,Object? displayName = freezed,Object? album = freezed,Object? mimeType = freezed,Object? createDate = freezed,Object? modifiedDate = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,createDate: freezed == createDate ? _self.createDate : createDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedDate: freezed == modifiedDate ? _self.modifiedDate : modifiedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [DevicePhoto].
extension DevicePhotoPatterns on DevicePhoto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DevicePhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DevicePhoto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DevicePhoto value)  $default,){
final _that = this;
switch (_that) {
case _DevicePhoto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DevicePhoto value)?  $default,){
final _that = this;
switch (_that) {
case _DevicePhoto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String mediaId,  String path,  int width,  int height,  int sizeBytes,  String? displayName,  String? album,  String? mimeType,  DateTime? createDate,  DateTime? modifiedDate,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DevicePhoto() when $default != null:
return $default(_that.mediaId,_that.path,_that.width,_that.height,_that.sizeBytes,_that.displayName,_that.album,_that.mimeType,_that.createDate,_that.modifiedDate,_that.latitude,_that.longitude);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String mediaId,  String path,  int width,  int height,  int sizeBytes,  String? displayName,  String? album,  String? mimeType,  DateTime? createDate,  DateTime? modifiedDate,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _DevicePhoto():
return $default(_that.mediaId,_that.path,_that.width,_that.height,_that.sizeBytes,_that.displayName,_that.album,_that.mimeType,_that.createDate,_that.modifiedDate,_that.latitude,_that.longitude);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String mediaId,  String path,  int width,  int height,  int sizeBytes,  String? displayName,  String? album,  String? mimeType,  DateTime? createDate,  DateTime? modifiedDate,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _DevicePhoto() when $default != null:
return $default(_that.mediaId,_that.path,_that.width,_that.height,_that.sizeBytes,_that.displayName,_that.album,_that.mimeType,_that.createDate,_that.modifiedDate,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DevicePhoto implements DevicePhoto {
  const _DevicePhoto({required this.mediaId, required this.path, required this.width, required this.height, required this.sizeBytes, this.displayName, this.album, this.mimeType, this.createDate, this.modifiedDate, this.latitude, this.longitude});
  factory _DevicePhoto.fromJson(Map<String, dynamic> json) => _$DevicePhotoFromJson(json);

@override final  String mediaId;
@override final  String path;
@override final  int width;
@override final  int height;
@override final  int sizeBytes;
@override final  String? displayName;
@override final  String? album;
@override final  String? mimeType;
@override final  DateTime? createDate;
@override final  DateTime? modifiedDate;
@override final  double? latitude;
@override final  double? longitude;

/// Create a copy of DevicePhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DevicePhotoCopyWith<_DevicePhoto> get copyWith => __$DevicePhotoCopyWithImpl<_DevicePhoto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DevicePhotoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DevicePhoto&&(identical(other.mediaId, mediaId) || other.mediaId == mediaId)&&(identical(other.path, path) || other.path == path)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.album, album) || other.album == album)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.createDate, createDate) || other.createDate == createDate)&&(identical(other.modifiedDate, modifiedDate) || other.modifiedDate == modifiedDate)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mediaId,path,width,height,sizeBytes,displayName,album,mimeType,createDate,modifiedDate,latitude,longitude);

@override
String toString() {
  return 'DevicePhoto(mediaId: $mediaId, path: $path, width: $width, height: $height, sizeBytes: $sizeBytes, displayName: $displayName, album: $album, mimeType: $mimeType, createDate: $createDate, modifiedDate: $modifiedDate, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$DevicePhotoCopyWith<$Res> implements $DevicePhotoCopyWith<$Res> {
  factory _$DevicePhotoCopyWith(_DevicePhoto value, $Res Function(_DevicePhoto) _then) = __$DevicePhotoCopyWithImpl;
@override @useResult
$Res call({
 String mediaId, String path, int width, int height, int sizeBytes, String? displayName, String? album, String? mimeType, DateTime? createDate, DateTime? modifiedDate, double? latitude, double? longitude
});




}
/// @nodoc
class __$DevicePhotoCopyWithImpl<$Res>
    implements _$DevicePhotoCopyWith<$Res> {
  __$DevicePhotoCopyWithImpl(this._self, this._then);

  final _DevicePhoto _self;
  final $Res Function(_DevicePhoto) _then;

/// Create a copy of DevicePhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mediaId = null,Object? path = null,Object? width = null,Object? height = null,Object? sizeBytes = null,Object? displayName = freezed,Object? album = freezed,Object? mimeType = freezed,Object? createDate = freezed,Object? modifiedDate = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_DevicePhoto(
mediaId: null == mediaId ? _self.mediaId : mediaId // ignore: cast_nullable_to_non_nullable
as String,path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,createDate: freezed == createDate ? _self.createDate : createDate // ignore: cast_nullable_to_non_nullable
as DateTime?,modifiedDate: freezed == modifiedDate ? _self.modifiedDate : modifiedDate // ignore: cast_nullable_to_non_nullable
as DateTime?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
