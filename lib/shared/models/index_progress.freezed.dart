// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'index_progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IndexProgress {

 int get processed; int get total; bool get isRunning; bool get isCompleted; String? get currentFileName;
/// Create a copy of IndexProgress
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IndexProgressCopyWith<IndexProgress> get copyWith => _$IndexProgressCopyWithImpl<IndexProgress>(this as IndexProgress, _$identity);

  /// Serializes this IndexProgress to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IndexProgress&&(identical(other.processed, processed) || other.processed == processed)&&(identical(other.total, total) || other.total == total)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.currentFileName, currentFileName) || other.currentFileName == currentFileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,processed,total,isRunning,isCompleted,currentFileName);

@override
String toString() {
  return 'IndexProgress(processed: $processed, total: $total, isRunning: $isRunning, isCompleted: $isCompleted, currentFileName: $currentFileName)';
}


}

/// @nodoc
abstract mixin class $IndexProgressCopyWith<$Res>  {
  factory $IndexProgressCopyWith(IndexProgress value, $Res Function(IndexProgress) _then) = _$IndexProgressCopyWithImpl;
@useResult
$Res call({
 int processed, int total, bool isRunning, bool isCompleted, String? currentFileName
});




}
/// @nodoc
class _$IndexProgressCopyWithImpl<$Res>
    implements $IndexProgressCopyWith<$Res> {
  _$IndexProgressCopyWithImpl(this._self, this._then);

  final IndexProgress _self;
  final $Res Function(IndexProgress) _then;

/// Create a copy of IndexProgress
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? processed = null,Object? total = null,Object? isRunning = null,Object? isCompleted = null,Object? currentFileName = freezed,}) {
  return _then(_self.copyWith(
processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,currentFileName: freezed == currentFileName ? _self.currentFileName : currentFileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [IndexProgress].
extension IndexProgressPatterns on IndexProgress {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IndexProgress value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IndexProgress() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IndexProgress value)  $default,){
final _that = this;
switch (_that) {
case _IndexProgress():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IndexProgress value)?  $default,){
final _that = this;
switch (_that) {
case _IndexProgress() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int processed,  int total,  bool isRunning,  bool isCompleted,  String? currentFileName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IndexProgress() when $default != null:
return $default(_that.processed,_that.total,_that.isRunning,_that.isCompleted,_that.currentFileName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int processed,  int total,  bool isRunning,  bool isCompleted,  String? currentFileName)  $default,) {final _that = this;
switch (_that) {
case _IndexProgress():
return $default(_that.processed,_that.total,_that.isRunning,_that.isCompleted,_that.currentFileName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int processed,  int total,  bool isRunning,  bool isCompleted,  String? currentFileName)?  $default,) {final _that = this;
switch (_that) {
case _IndexProgress() when $default != null:
return $default(_that.processed,_that.total,_that.isRunning,_that.isCompleted,_that.currentFileName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IndexProgress extends IndexProgress {
  const _IndexProgress({this.processed = 0, this.total = 0, this.isRunning = false, this.isCompleted = false, this.currentFileName}): super._();
  factory _IndexProgress.fromJson(Map<String, dynamic> json) => _$IndexProgressFromJson(json);

@override@JsonKey() final  int processed;
@override@JsonKey() final  int total;
@override@JsonKey() final  bool isRunning;
@override@JsonKey() final  bool isCompleted;
@override final  String? currentFileName;

/// Create a copy of IndexProgress
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IndexProgressCopyWith<_IndexProgress> get copyWith => __$IndexProgressCopyWithImpl<_IndexProgress>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IndexProgressToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IndexProgress&&(identical(other.processed, processed) || other.processed == processed)&&(identical(other.total, total) || other.total == total)&&(identical(other.isRunning, isRunning) || other.isRunning == isRunning)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted)&&(identical(other.currentFileName, currentFileName) || other.currentFileName == currentFileName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,processed,total,isRunning,isCompleted,currentFileName);

@override
String toString() {
  return 'IndexProgress(processed: $processed, total: $total, isRunning: $isRunning, isCompleted: $isCompleted, currentFileName: $currentFileName)';
}


}

/// @nodoc
abstract mixin class _$IndexProgressCopyWith<$Res> implements $IndexProgressCopyWith<$Res> {
  factory _$IndexProgressCopyWith(_IndexProgress value, $Res Function(_IndexProgress) _then) = __$IndexProgressCopyWithImpl;
@override @useResult
$Res call({
 int processed, int total, bool isRunning, bool isCompleted, String? currentFileName
});




}
/// @nodoc
class __$IndexProgressCopyWithImpl<$Res>
    implements _$IndexProgressCopyWith<$Res> {
  __$IndexProgressCopyWithImpl(this._self, this._then);

  final _IndexProgress _self;
  final $Res Function(_IndexProgress) _then;

/// Create a copy of IndexProgress
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? processed = null,Object? total = null,Object? isRunning = null,Object? isCompleted = null,Object? currentFileName = freezed,}) {
  return _then(_IndexProgress(
processed: null == processed ? _self.processed : processed // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,isRunning: null == isRunning ? _self.isRunning : isRunning // ignore: cast_nullable_to_non_nullable
as bool,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,currentFileName: freezed == currentFileName ? _self.currentFileName : currentFileName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
