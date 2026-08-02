import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:pinpic/services/tflite_classifier_service.dart';

class VisionService {
  /// Minimum confidence for object-detector sub-labels. The detector's own
  /// `classifyObjects` threshold is more permissive than the image labeler's,
  /// which let low-confidence guesses (e.g. a rock photo tagged "Food") leak
  /// into `objects`/`category` and made search look randomly wrong.
  static const _objectLabelConfidenceThreshold = 0.65;

  VisionService({TfliteClassifierService? tfliteClassifier})
    : _labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.65),
      ),
      _detector = ObjectDetector(
        options: ObjectDetectorOptions(
          mode: DetectionMode.single,
          classifyObjects: true,
          multipleObjects: true,
        ),
      ),
      _tflite = tfliteClassifier ?? TfliteClassifierService();

  final ImageLabeler _labeler;
  final ObjectDetector _detector;
  final TfliteClassifierService _tflite;

  Future<List<String>> detectLabelsAndObjects(String path) async {
    final file = File(path);
    if (!await file.exists()) return const [];

    final labels = <String>{};
    final input = InputImage.fromFilePath(path);

    // TFLite MobileNet is the primary scene classifier for common gallery
    // content (food/animals/cars/plants). ML Kit remains as a complementary
    // signal for labels MobileNet doesn't cover well.
    try {
      final tfliteLabels = await _tflite.classify(path);
      labels.addAll(tfliteLabels);
    } catch (error, stack) {
      debugPrint('TFLite vision pass failed for $path: $error\n$stack');
    }

    try {
      final imageLabels = await _labeler.processImage(input);
      if (kDebugMode) {
        final dump = imageLabels
            .map((l) => '${l.label}:${l.confidence.toStringAsFixed(2)}')
            .join(', ');
        debugPrint('ImageLabeler[$path]: $dump');
      }
      for (final label in imageLabels) {
        final text = label.label.trim();
        if (text.isNotEmpty) labels.add(text);
      }
    } catch (error, stack) {
      debugPrint('ImageLabeler failed for $path: $error\n$stack');
    }

    try {
      final objects = await _detector.processImage(input);
      if (kDebugMode) {
        final dump = objects
            .expand((o) => o.labels)
            .map((l) => '${l.text}:${l.confidence.toStringAsFixed(2)}')
            .join(', ');
        debugPrint('ObjectDetector[$path]: $dump');
      }
      for (final object in objects) {
        for (final label in object.labels) {
          if (label.confidence < _objectLabelConfidenceThreshold) continue;
          final text = label.text.trim();
          if (text.isNotEmpty) labels.add(text);
        }
      }
    } catch (error, stack) {
      debugPrint('ObjectDetector failed for $path: $error\n$stack');
    }

    // Conflict cleanup: stronger scene signals beat known ML hallucinations.
    final lower = labels.map((l) => l.toLowerCase()).toSet();
    if (lower.contains('stone') || lower.contains('rock')) {
      labels.removeWhere((label) {
        final value = label.toLowerCase();
        return value == 'food' || value == 'meal' || value == 'dish';
      });
    }
    // A camera / tripod scene must not stay tagged as Animal because MobileNet
    // also guessed "teddy". Keep Camera searchable; drop the wildlife noise.
    if (lower.contains('camera') || lower.contains('tripod')) {
      labels.removeWhere((label) {
        final value = label.toLowerCase();
        return value == 'animal' ||
            value == 'wildlife' ||
            value == 'pet' ||
            value == 'teddy' ||
            value == 'toy' ||
            value == 'bear';
      });
    }

    if (kDebugMode && labels.isEmpty) {
      debugPrint('VisionService: no labels detected for $path');
    }

    return labels.toList(growable: false);
  }

  Future<void> dispose() async {
    await _labeler.close();
    await _detector.close();
    await _tflite.dispose();
  }
}
