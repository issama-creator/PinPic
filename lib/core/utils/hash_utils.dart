import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract final class HashUtils {
  /// Bump when index interpretation changes. It makes the next normal scan
  /// refresh stored categories/keywords once instead of keeping stale labels.
  static const indexPipelineVersion = 15;

  static String sha256OfString(String value) {
    final bytes = utf8.encode(value);
    return sha256.convert(bytes).toString();
  }

  static String photoFingerprint({
    required String mediaId,
    required int width,
    required int height,
    required int sizeBytes,
    DateTime? modifiedAt,
  }) {
    final payload = [
      indexPipelineVersion,
      mediaId,
      width,
      height,
      sizeBytes,
      modifiedAt?.millisecondsSinceEpoch ?? 0,
    ].join('|');
    return sha256OfString(payload);
  }
}
