import 'dart:convert';

import 'package:crypto/crypto.dart';

abstract final class HashUtils {
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
      mediaId,
      width,
      height,
      sizeBytes,
      modifiedAt?.millisecondsSinceEpoch ?? 0,
    ].join('|');
    return sha256OfString(payload);
  }
}
