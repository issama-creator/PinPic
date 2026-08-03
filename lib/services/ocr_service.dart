import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pinpic/services/deep_ocr_bridge.dart';
import 'package:pinpic/services/fast_image_prep.dart';

/// Fast ML Kit Latin OCR + offline PP-OCRv5 Cyrillic deep pass on Android.
///
/// Indexing keeps the two passes separate so search becomes available before
/// deep OCR finishes. A small pool of recognizers lets the indexer process
/// multiple photos without serializing every ML Kit call.
class OcrService {
  OcrService({DeepOcrBridge? deepOcr, int poolSize = 2})
    : _recognizers = List<TextRecognizer>.generate(
        poolSize.clamp(1, 4),
        (_) => TextRecognizer(script: TextRecognitionScript.latin),
        growable: false,
      ),
      _deepOcr = deepOcr ?? DeepOcrBridge() {
    _available.addAll(List<int>.generate(_recognizers.length, (i) => i));
  }

  final List<TextRecognizer> _recognizers;
  final DeepOcrBridge _deepOcr;
  final List<int> _available = <int>[];
  final Queue<Completer<int>> _waiters = Queue<Completer<int>>();

  static const fastOcrMaxEdge = FastImagePrep.maxEdge;

  Future<int> _acquire() {
    if (_available.isNotEmpty) {
      return Future<int>.value(_available.removeLast());
    }
    final gate = Completer<int>();
    _waiters.add(gate);
    return gate.future;
  }

  void _release(int index) {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete(index);
    } else {
      _available.add(index);
    }
  }

  /// Legacy complete OCR API.
  Future<String?> extractText(String path) async {
    final fastText = await extractFastText(path);
    if (!needsDeepText(fastText)) return fastText;
    final deepText = await extractDeepText(path);
    return mergeTexts(fastText, deepText);
  }

  /// Low-latency Latin/digits OCR. Pass [preparedPath] when already downscaled.
  Future<String?> extractFastText(
    String path, {
    String? preparedPath,
  }) async {
    final preferred = preparedPath ?? path;
    if (!await File(preferred).exists()) return null;

    File? ownedTemp;
    try {
      var inputPath = preferred;
      if (preparedPath == null) {
        inputPath = await _fastInputPath(path);
        if (inputPath != path) ownedTemp = File(inputPath);
      }

      final slot = await _acquire();
      try {
        final input = InputImage.fromFilePath(inputPath);
        final result = await _recognizers[slot].processImage(input);
        final text = result.text.trim();
        if (kDebugMode) {
          debugPrint(
            'OCR(fast)[$path]: ${text.isEmpty ? '<empty>' : text.replaceAll('\n', ' | ')}',
          );
        }
        return text.isEmpty ? null : text;
      } finally {
        _release(slot);
      }
    } catch (error, stack) {
      debugPrint('OCR(mlkit) failed for $path: $error\n$stack');
      return null;
    } finally {
      if (ownedTemp != null) {
        try {
          await ownedTemp.delete();
        } catch (_) {}
      }
    }
  }

  Future<String> _fastInputPath(String path) async {
    final prepared = await FastImagePrep.preparePath(path);
    return prepared ?? path;
  }

  Future<bool> warmupDeepOcr() => _deepOcr.warmup();

  /// High-quality offline Cyrillic OCR (PP-OCRv5).
  Future<String?> extractDeepText(
    String path, {
    bool aggressive = true,
  }) async {
    final file = File(path);
    if (!await file.exists()) return null;

    try {
      final text = await _deepOcr.recognize(path, aggressive: aggressive);
      if (kDebugMode) {
        debugPrint(
          'OCR(deep)[$path]: ${text == null || text.isEmpty ? '<empty>' : text.replaceAll('\n', ' | ')}',
        );
      }
      return text;
    } catch (error, stack) {
      debugPrint('OCR(deep) failed for $path: $error\n$stack');
      return null;
    }
  }

  /// Full re-read used by the photo details "Перечитать" action.
  Future<String?> extractBestText(String path) async {
    final fast = await extractFastText(path);
    final deep = await extractDeepText(path, aggressive: true);
    return pickRicherText(fast, deep) ?? mergeTexts(fast, deep);
  }

  bool needsDeepText(String? fastText) {
    final text = fastText?.trim() ?? '';
    if (text.isEmpty) return true;
    final latinLetters = RegExp(r'[a-zA-Z]').allMatches(text).length;
    if (latinLetters < 8) return true;

    const usefulLatinTerms = {
      'boarding',
      'contract',
      'document',
      'ikea',
      'invoice',
      'login',
      'passport',
      'password',
      'receipt',
      'ticket',
      'total',
      'warranty',
      'prescription',
    };
    final words = RegExp(
      r'[a-zA-Z]+',
    ).allMatches(text.toLowerCase()).map((match) => match.group(0)!);
    return !words.any(usefulLatinTerms.contains);
  }

  String? mergeTexts(String? fastText, String? deepText) {
    final parts = <String>{
      if (fastText != null && fastText.trim().isNotEmpty) fastText.trim(),
      if (deepText != null && deepText.trim().isNotEmpty) deepText.trim(),
    };
    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  String? pickRicherText(String? a, String? b) {
    final left = a?.trim();
    final right = b?.trim();
    if (left == null || left.isEmpty) return right;
    if (right == null || right.isEmpty) return left;
    final leftScore = scoreText(left);
    final rightScore = scoreText(right);
    if (rightScore >= leftScore * 1.15) return right;
    if (leftScore >= rightScore * 1.15) return left;
    return mergeTexts(left, right);
  }

  static int scoreText(String text) {
    if (text.isEmpty) return 0;
    var letters = 0;
    var cyrillic = 0;
    var digits = 0;
    for (final unit in text.runes) {
      final ch = String.fromCharCode(unit);
      if (RegExp(r'[А-Яа-яЁё]').hasMatch(ch)) {
        cyrillic++;
        letters++;
      } else if (RegExp(r'[A-Za-z]').hasMatch(ch)) {
        letters++;
      } else if (RegExp(r'\d').hasMatch(ch)) {
        digits++;
      }
    }
    return letters + cyrillic * 2 + digits + text.length ~/ 5;
  }

  Future<void> dispose() async {
    for (final recognizer in _recognizers) {
      await recognizer.close();
    }
  }
}
