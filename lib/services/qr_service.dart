import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class QrScanResult {
  const QrScanResult({required this.hasQr, this.payload});

  final bool hasQr;
  final String? payload;
}

class QrService {
  QrService({int poolSize = 2})
    : _scanners = List<BarcodeScanner>.generate(
        poolSize.clamp(1, 4),
        (_) => BarcodeScanner(formats: [BarcodeFormat.qrCode]),
        growable: false,
      ) {
    _available.addAll(List<int>.generate(_scanners.length, (i) => i));
  }

  final List<BarcodeScanner> _scanners;
  final List<int> _available = <int>[];
  final Queue<Completer<int>> _waiters = Queue<Completer<int>>();

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

  Future<QrScanResult> scan(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return const QrScanResult(hasQr: false);
    }

    final slot = await _acquire();
    try {
      final barcodes = await _scanners[slot].processImage(
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
    } finally {
      _release(slot);
    }
  }

  Future<void> dispose() async {
    for (final scanner in _scanners) {
      await scanner.close();
    }
  }
}
