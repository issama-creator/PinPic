import 'package:freezed_annotation/freezed_annotation.dart';

part 'index_progress.freezed.dart';
part 'index_progress.g.dart';

@freezed
abstract class IndexProgress with _$IndexProgress {
  const factory IndexProgress({
    @Default(0) int processed,
    @Default(0) int total,
    @Default(false) bool isRunning,
    @Default(false) bool isCompleted,
    String? currentFileName,
  }) = _IndexProgress;

  const IndexProgress._();

  factory IndexProgress.fromJson(Map<String, dynamic> json) =>
      _$IndexProgressFromJson(json);

  double get fraction {
    if (total <= 0) return 0;
    return (processed / total).clamp(0, 1);
  }

  String get label => '$processed / $total';
}
