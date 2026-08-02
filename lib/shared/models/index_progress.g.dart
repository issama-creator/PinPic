// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IndexProgress _$IndexProgressFromJson(Map<String, dynamic> json) =>
    _IndexProgress(
      processed: (json['processed'] as num?)?.toInt() ?? 0,
      total: (json['total'] as num?)?.toInt() ?? 0,
      isRunning: json['isRunning'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      currentFileName: json['currentFileName'] as String?,
    );

Map<String, dynamic> _$IndexProgressToJson(_IndexProgress instance) =>
    <String, dynamic>{
      'processed': instance.processed,
      'total': instance.total,
      'isRunning': instance.isRunning,
      'isCompleted': instance.isCompleted,
      'currentFileName': instance.currentFileName,
    };
