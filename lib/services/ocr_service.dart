import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:pinpic/services/deep_ocr_bridge.dart';

/// Fast ML Kit Latin OCR + offline PP-OCRv5 Cyrillic deep pass on Android.
///
/// ML Kit has no Cyrillic script option. The deep pass (NCNN PaddleOCR v5
/// with the eslav dictionary) fills that gap for tickets, passports and
/// other Russian document photos. Indexing keeps the two passes separate so
/// search becomes available before deep OCR finishes.
///
/// Deep OCR on Android also runs contrast/upscale preprocess and retries
/// rotated frames when the first pass looks weak.
class OcrService {
  OcrService({DeepOcrBridge? deepOcr})
    : _recognizer = TextRecognizer(script: TextRecognitionScript.latin),
      _deepOcr = deepOcr ?? DeepOcrBridge();

  final TextRecognizer _recognizer;
  final DeepOcrBridge _deepOcr;

  /// Long edge for the fast ML Kit pass — full 12MP frames are wasted work.
  static const fastOcrMaxEdge = 1280;

  /// Legacy complete OCR API. Indexing uses the two explicit passes below so
  /// the quick index can become searchable before deep OCR finishes.
  Future<String?> extractText(String path) async {
    final fastText = await extractFastText(path);
    if (!needsDeepText(fastText)) return fastText;
    final deepText = await extractDeepText(path);
    return mergeTexts(fastText, deepText);
  }

  /// Low-latency Latin/digits OCR. Enough for many receipts and filenames.
  Future<String?> extractFastText(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    File? temp;
    try {
      final inputPath = await _fastInputPath(path);
      if (inputPath != path) temp = File(inputPath);
      final input = InputImage.fromFilePath(inputPath);
      final result = await _recognizer.processImage(input);
      final text = result.text.trim();
      if (kDebugMode) {
        debugPrint(
          'OCR(fast)[$path]: ${text.isEmpty ? '<empty>' : text.replaceAll('\n', ' | ')}',
        );
      }
      return text.isEmpty ? null : text;
    } catch (error, stack) {
      debugPrint('OCR(mlkit) failed for $path: $error\n$stack');
      return null;
    } finally {
      if (temp != null) {
        try {
          await temp.delete();
        } catch (_) {}
      }
    }
  }

  /// Downscale large gallery photos before ML Kit; leave small files alone.
  Future<String> _fastInputPath(String path) async {
    try {
      final bytes = await compute(_downscaleForFastOcr, path);
      if (bytes == null) return path;
      final temp = File(
        '${Directory.systemTemp.path}'
        '${Platform.pathSeparator}pinpic_ocr_${identityHashCode(path)}_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await temp.writeAsBytes(bytes, flush: true);
      return temp.path;
    } catch (_) {
      return path;
    }
  }

  /// High-quality offline Cyrillic OCR (PP-OCRv5). Prefer [aggressive] for
  /// documents so preprocess + rotation retries can recover sideways shots.
  Future<String?> extractDeepText(
    String path, {
    bool aggressive = true,
  }) async {
    final file = File(path);
    if (!await file.exists()) return null;

    if (!await _canDecodeAsBitmap(path)) {
      if (kDebugMode) {
        debugPrint('OCR(deep) skipped, not a decodable bitmap: $path');
      }
      return null;
    }

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

  /// Deep OCR is needed unless ML Kit extracted recognisable Latin text.
  /// ML Kit only supports Latin and often turns Cyrillic letters into
  /// convincing-looking gibberish (for example, «БИЛЕТ»). Letter count alone
  /// is therefore unsafe: it would skip deep OCR for exactly these documents.
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

  /// Prefer the richer single pass (usually deep) over a noisy merge when one
  /// clearly dominates — keeps search keywords cleaner.
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

  Future<bool> _canDecodeAsBitmap(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 32);
      await codec.getNextFrame();
      codec.dispose();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() => _recognizer.close();
}

/// Returns JPEG bytes when [path] is larger than [OcrService.fastOcrMaxEdge],
/// otherwise null (caller should use the original file).
Uint8List? _downscaleForFastOcr(String path) {
  try {
    final raw = File(path).readAsBytesSync();
    final decoded = img.decodeImage(raw);
    if (decoded == null) return null;
    final maxEdge = math.max(decoded.width, decoded.height);
    if (maxEdge <= OcrService.fastOcrMaxEdge) return null;
    final scale = OcrService.fastOcrMaxEdge / maxEdge;
    final resized = img.copyResize(
      decoded,
      width: math.max(1, (decoded.width * scale).round()),
      height: math.max(1, (decoded.height * scale).round()),
      interpolation: img.Interpolation.average,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: 78));
  } catch (_) {
    return null;
  }
}
