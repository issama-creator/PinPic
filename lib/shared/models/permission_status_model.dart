enum PhotoPermissionStatus {
  granted,
  limited,
  denied,
  permanentlyDenied,
  restricted,
  unknown,
}

extension PhotoPermissionStatusX on PhotoPermissionStatus {
  bool get isGranted =>
      this == PhotoPermissionStatus.granted ||
      this == PhotoPermissionStatus.limited;

  bool get canRequestAgain =>
      this == PhotoPermissionStatus.denied ||
      this == PhotoPermissionStatus.unknown;
}
