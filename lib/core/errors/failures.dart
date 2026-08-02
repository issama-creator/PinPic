import 'package:pinpic/core/errors/exceptions.dart';

sealed class Failure {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

class MediaFailure extends Failure {
  const MediaFailure(super.message, {super.code});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});
}

Failure mapExceptionToFailure(Object error) {
  if (error is PermissionException) {
    return PermissionFailure(error.message, code: error.code);
  }
  if (error is DatabaseException) {
    return DatabaseFailure(error.message, code: error.code);
  }
  if (error is MediaException) {
    return MediaFailure(error.message, code: error.code);
  }
  if (error is AppException) {
    return UnexpectedFailure(error.message, code: error.code);
  }
  return UnexpectedFailure(error.toString());
}
