import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:photo_manager/photo_manager.dart';

/// Shared downscale for fast OCR + QR — one decode per photo, not two.
abstract final class FastImagePrep {
  /// Large enough for small receipt text and QR modules, while avoiding a
  /// full 12–50 MP decode in both ML Kit pipelines.
  static const maxEdge = 1920;

  /// Prefer native MediaStore thumbnail when [mediaId] is known.
  static Future<String?> prepare({
    required String mediaId,
    required String path,
    required int width,
    required int height,
  }) async {
    if (width > 0 && height > 0 && math.max(width, height) <= maxEdge) {
      return null;
    }
    try {
      final asset = await AssetEntity.fromId(mediaId);
      final bytes = await asset?.thumbnailDataWithSize(
        const ThumbnailSize(maxEdge, maxEdge),
        quality: 88,
        format: ThumbnailFormat.jpeg,
      );
      final preparedBytes = bytes ?? await compute(_prepareBytes, path);
      return _writeTemp(preparedBytes, path);
    } catch (_) {
      return preparePath(path);
    }
  }

  /// Path-only fallback (no MediaStore id).
  static Future<String?> preparePath(String path) async {
    try {
      final bytes = await compute(_prepareBytes, path);
      return _writeTemp(bytes, path);
    } catch (_) {
      return null;
    }
  }

  static Future<String?> _writeTemp(Uint8List? bytes, String path) async {
    if (bytes == null) return null;
    final temp = File(
      '${Directory.systemTemp.path}'
      '${Platform.pathSeparator}pinpic_prep_'
      '${identityHashCode(path)}_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await temp.writeAsBytes(bytes);
    return temp.path;
  }

  static Future<void> disposePrepared(String? preparedPath) async {
    if (preparedPath == null) return;
    try {
      await File(preparedPath).delete();
    } catch (_) {}
  }
}

Uint8List? _prepareBytes(String path) {
  try {
    final raw = File(path).readAsBytesSync();
    final decoded = img.decodeImage(raw);
    if (decoded == null) return null;
    final edge = math.max(decoded.width, decoded.height);
    if (edge <= FastImagePrep.maxEdge) return null;
    final scale = FastImagePrep.maxEdge / edge;
    final resized = img.copyResize(
      decoded,
      width: math.max(1, (decoded.width * scale).round()),
      height: math.max(1, (decoded.height * scale).round()),
      interpolation: img.Interpolation.linear,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: 88));
  } catch (_) {
    return null;
  }
}
