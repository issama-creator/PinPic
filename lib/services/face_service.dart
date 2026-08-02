import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Dedicated face detection for the "Люди" category.
///
/// The generic image labeler/object detector only guess broad scene labels
/// ("Person", "Fashion good") and often miss people in stylised, cropped or
/// unusually lit photos. ML Kit's face detector is a specialised model that
/// reliably finds faces even when the general labeler doesn't, so it is a
/// much stronger signal for "this photo is of a person".
class FaceService {
  FaceService()
    : _detector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast,
          minFaceSize: 0.1,
        ),
      );

  final FaceDetector _detector;

  Future<bool> hasFace(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;

    try {
      final input = InputImage.fromFilePath(path);
      final faces = await _detector.processImage(input);
      return faces.isNotEmpty;
    } catch (error, stack) {
      debugPrint('FaceService failed for $path: $error\n$stack');
      return false;
    }
  }

  Future<void> dispose() async {
    await _detector.close();
  }
}
