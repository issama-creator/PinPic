import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:pinpic/shared/models/permission_status_model.dart';

class PermissionService {
  Future<PhotoPermissionStatus> checkPhotoPermission() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );
    return _mapPermissionState(state);
  }

  Future<PhotoPermissionStatus> requestPhotoPermission() async {
    final state = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission: AndroidPermission(
          type: RequestType.image,
          mediaLocation: false,
        ),
      ),
    );

    if (state.isAuth || state.hasAccess) {
      return _mapPermissionState(state);
    }

    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted || photos.isLimited) {
        return photos.isLimited
            ? PhotoPermissionStatus.limited
            : PhotoPermissionStatus.granted;
      }

      final storage = await Permission.storage.request();
      if (storage.isGranted) {
        return PhotoPermissionStatus.granted;
      }
      if (storage.isPermanentlyDenied || photos.isPermanentlyDenied) {
        return PhotoPermissionStatus.permanentlyDenied;
      }
      return PhotoPermissionStatus.denied;
    }

    return _mapPermissionState(state);
  }

  Future<bool> openSystemSettings() {
    return openAppSettings();
  }

  PhotoPermissionStatus _mapPermissionState(PermissionState state) {
    if (state == PermissionState.authorized) {
      return PhotoPermissionStatus.granted;
    }
    if (state == PermissionState.limited) {
      return PhotoPermissionStatus.limited;
    }
    if (state == PermissionState.denied) {
      return PhotoPermissionStatus.denied;
    }
    if (state == PermissionState.restricted) {
      return PhotoPermissionStatus.restricted;
    }
    return PhotoPermissionStatus.unknown;
  }
}
