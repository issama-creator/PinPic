class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

class MediaException extends AppException {
  const MediaException(super.message, {super.code});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}
