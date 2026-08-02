import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class QrScanResult {
  const QrScanResult({required this.hasQr, this.payload});

  final bool hasQr;
  final String? payload;
}

class QrService {
  QrService()
    : _scanner = BarcodeScanner(
        formats: [
          BarcodeFormat.qrCode,
          BarcodeFormat.aztec,
          BarcodeFormat.dataMatrix,
        ],
      );

  final BarcodeScanner _scanner;

  Future<QrScanResult> scan(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const QrScanResult(hasQr: false);
    }

    try {
      final barcodes = await _scanner.processImage(
        InputImage.fromFilePath(path),
      );
      if (barcodes.isEmpty) {
        return const QrScanResult(hasQr: false);
      }
      final payload = barcodes
          .map((b) => b.rawValue)
          .whereType<String>()
          .where((v) => v.trim().isNotEmpty)
          .join(' ');
      return QrScanResult(
        hasQr: true,
        payload: payload.isEmpty ? null : payload,
      );
    } catch (_) {
      return const QrScanResult(hasQr: false);
    }
  }

  Future<void> dispose() => _scanner.close();
}
