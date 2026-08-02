import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

/// ML Kit's on-device text recognizer has no Cyrillic script option — only
/// latin/chinese/devanagari/japanese/korean — so it can't read Russian text
/// at all (confirmed limitation, not a config mistake). Tesseract (fully
/// offline, bundled `rus`+`eng` trained data) fills that gap. Both engines
/// run and their output is merged: ML Kit is fast and very accurate for
/// Latin text/digits, Tesseract covers Cyrillic (and backs up Latin too).
class OcrService {
  OcrService()
    : _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final TextRecognizer _recognizer;

  static const _tesseractConfig = OCRConfig(
    language: 'rus+eng',
    engine: OCREngine.tesseract,
  );

  Future<String?> extractText(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final texts = <String>[];

    try {
      final input = InputImage.fromFilePath(path);
      final result = await _recognizer.processImage(input);
      final text = result.text.trim();
      if (text.isNotEmpty) texts.add(text);
      if (kDebugMode) {
        debugPrint(
          'OCR(mlkit)[$path]: ${text.isEmpty ? '<empty>' : text.replaceAll('\n', ' | ')}',
        );
      }
    } catch (error, stack) {
      debugPrint('OCR(mlkit) failed for $path: $error\n$stack');
    }

    // The tesseract_ocr plugin's native decode step has no exception
    // handling on its background Java thread: a file it can't decode as a
    // bitmap (SVG, corrupted download, etc.) throws an *uncaught*
    // RuntimeException there and crashes the whole app process, not just
    // this call. Dart-side try/catch can't protect against a native crash,
    // so we verify the file is a genuine decodable raster image ourselves
    // first and skip Tesseract entirely if it isn't.
    if (await _canDecodeAsBitmap(path)) {
      String? contrastPath;
      try {
        // Bright graphic tickets (green bg + bold Cyrillic) often lose words
        // to Tesseract on the raw file; a grayscale+contrast pass helps.
        contrastPath = await _writeContrastCopy(path);
        final raw = await TesseractOcr.extractText(
          contrastPath ?? path,
          config: _tesseractConfig,
        );
        final text = raw.trim();
        if (text.isNotEmpty) texts.add(text);
        if (kDebugMode) {
          debugPrint(
            'OCR(tesseract)[$path]: ${text.isEmpty ? '<empty>' : text.replaceAll('\n', ' | ')}',
          );
        }
      } catch (error, stack) {
        debugPrint('OCR(tesseract) failed for $path: $error\n$stack');
      } finally {
        if (contrastPath != null) {
          try {
            await File(contrastPath).delete();
          } catch (_) {}
        }
      }
    } else if (kDebugMode) {
      debugPrint('OCR(tesseract) skipped, not a decodable bitmap: $path');
    }

    if (texts.isEmpty) return null;
    return texts.join('\n');
  }

  /// Grayscale + contrast boost → temp JPEG for Tesseract. Returns null if
  /// preprocessing fails (caller then uses the original path).
  Future<String?> _writeContrastCopy(String path) async {
    try {
      final raw = await File(path).readAsBytes();
      final decoded = img.decodeImage(raw);
      if (decoded == null) return null;

      // Cap long edge so huge gallery photos don't stall indexing.
      final longest = decoded.width > decoded.height
          ? decoded.width
          : decoded.height;
      final sized = longest > 1600
          ? img.copyResize(
              decoded,
              width: decoded.width >= decoded.height ? 1600 : null,
              height: decoded.height > decoded.width ? 1600 : null,
            )
          : decoded;

      final gray = img.grayscale(sized);
      final boosted = img.adjustColor(gray, contrast: 1.35);
      final bytes = img.encodeJpg(boosted, quality: 92);

      final dir = await getTemporaryDirectory();
      final out = File(
        '${dir.path}/pinpic_ocr_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );
      await out.writeAsBytes(bytes, flush: true);
      return out.path;
    } catch (error) {
      debugPrint('OCR contrast preprocess failed for $path: $error');
      return null;
    }
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
