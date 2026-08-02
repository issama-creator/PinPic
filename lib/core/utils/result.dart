import 'package:pinpic/core/errors/failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Err<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Err<T>() => null,
  };

  Failure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Err<T>(:final failure) => failure,
  };

  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final value) => success(value),
      Err<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}
