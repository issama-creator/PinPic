import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android MethodChannel bridge to bundled PP-OCRv5 (eslav) deep OCR.
class DeepOcrBridge {
  DeepOcrBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('com.pinpic.app/deep_ocr');

  final MethodChannel _channel;
  Future<bool>? _warmup;

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  Future<bool> warmup() {
    if (!isSupported) return Future.value(false);
    return _warmup ??= _channel
        .invokeMethod<bool>('warmup')
        .then((value) => value ?? false)
        .catchError((Object error, StackTrace stack) {
          debugPrint('Deep OCR warmup failed: $error\n$stack');
          return false;
        });
  }

  Future<String?> recognize(String path, {bool aggressive = true}) async {
    if (!isSupported) return null;
    try {
      await warmup();
      final text = await _channel.invokeMethod<String>('recognize', {
        'path': path,
        'aggressive': aggressive,
      });
      final trimmed = text?.trim();
      if (trimmed == null || trimmed.isEmpty) return null;
      return trimmed;
    } catch (error, stack) {
      debugPrint('Deep OCR failed for $path: $error\n$stack');
      return null;
    }
  }
}
