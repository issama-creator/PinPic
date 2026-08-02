import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:pinpic/services/imagenet_label_mapper.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// On-device ImageNet classifier (MobileNet V1 quantized) used as a second
/// vision pass alongside ML Kit. More reliable for common gallery scenes
/// (food, animals, cars, plants) than the generic ML Kit labeler alone.
class TfliteClassifierService {
  static const _modelAsset = 'assets/models/mobilenet_v1.tflite';
  static const _labelsAsset = 'assets/models/imagenet_labels.txt';
  static const _inputSize = 224;
  static const _topK = 5;
  /// Keep predictions whose score is at least this fraction of the top score.
  static const _relativeThreshold = 0.35;

  Interpreter? _interpreter;
  List<String> _labels = const [];
  bool _loading = false;
  bool _failed = false;

  Future<void> _ensureLoaded() async {
    if (_interpreter != null || _failed || _loading) return;
    _loading = true;
    try {
      final options = InterpreterOptions()..threads = 2;
      if (Platform.isAndroid) {
        try {
          options.addDelegate(XNNPackDelegate());
        } catch (_) {
          // XNNPACK may be unavailable on some emulators — CPU fallback is fine.
        }
      }
      _interpreter = await Interpreter.fromAsset(_modelAsset, options: options);
      final raw = await rootBundle.loadString(_labelsAsset);
      _labels = raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList(growable: false);
      if (kDebugMode) {
        debugPrint(
          'TFLite loaded: input=${_interpreter!.getInputTensors().first.shape} '
          'output=${_interpreter!.getOutputTensors().first.shape} '
          'labels=${_labels.length}',
        );
      }
    } catch (error, stack) {
      _failed = true;
      debugPrint('TFLite load failed: $error\n$stack');
    } finally {
      _loading = false;
    }
  }

  /// Returns PinPic-ready object labels for [path], or [] on any failure.
  Future<List<String>> classify(String path) async {
    await _ensureLoaded();
    final interpreter = _interpreter;
    if (interpreter == null || _labels.isEmpty) return const [];

    try {
      final file = File(path);
      if (!await file.exists()) return const [];
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return const [];

      final resized = img.copyResize(
        decoded,
        width: _inputSize,
        height: _inputSize,
        interpolation: img.Interpolation.linear,
      );

      // Quantized MobileNet expects uint8 RGB [1,224,224,3].
      final input = [
        List.generate(
          _inputSize,
          (y) => List.generate(_inputSize, (x) {
            final pixel = resized.getPixel(x, y);
            return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
          }),
        ),
      ];

      final outputTensor = interpreter.getOutputTensors().first;
      final outputLength = outputTensor.shape.last;
      final output = [List<int>.filled(outputLength, 0)];
      interpreter.run(input, output);

      final scores = output.first;
      final ranked = <({int index, int score})>[];
      for (var i = 0; i < scores.length && i < _labels.length; i++) {
        if (scores[i] > 0) ranked.add((index: i, score: scores[i]));
      }
      ranked.sort((a, b) => b.score.compareTo(a.score));
      if (ranked.isEmpty) return const [];

      final topScore = ranked.first.score;
      final minScore = math.max(1, (topScore * _relativeThreshold).round());
      final kept = ranked
          .where((item) => item.score >= minScore)
          .take(_topK)
          .toList(growable: false);

      final labels = <String>{};
      for (final item in kept) {
        final raw = _labels[item.index];
        labels.addAll(ImagenetLabelMapper.expand(raw));
      }

      if (kDebugMode) {
        final dump = kept
            .map((item) {
              final raw = _labels[item.index];
              final conf = (item.score / math.max(topScore, 1) * 100)
                  .toStringAsFixed(0);
              return '$raw:$conf%';
            })
            .join(', ');
        debugPrint('TFLite[$path]: $dump → ${labels.join(', ')}');
      }

      return labels.toList(growable: false);
    } catch (error, stack) {
      debugPrint('TFLite classify failed for $path: $error\n$stack');
      return const [];
    }
  }

  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
  }
}
