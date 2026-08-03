import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Opens an indexed photo in the system gallery / image viewer.
class MediaOpenService {
  MediaOpenService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.pinpic.app/media');

  final MethodChannel _channel;

  Future<bool> openInGallery({
    required String mediaId,
    required String path,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return false;
    try {
      final opened = await _channel.invokeMethod<bool>('openInGallery', {
        'mediaId': mediaId,
        'path': path,
      });
      return opened ?? false;
    } catch (error, stack) {
      debugPrint('openInGallery failed: $error\n$stack');
      return false;
    }
  }
}
