import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final sourceFile = File('images/logo_original.png');
  if (!sourceFile.existsSync()) {
    stderr.writeln('images/logo_original.png not found');
    exit(1);
  }

  final source = img.decodeImage(sourceFile.readAsBytesSync());
  if (source == null) {
    stderr.writeln('Failed to decode logo');
    exit(1);
  }

  final width = source.width;
  final height = source.height;

  // Canvas ~ (1,0,11), plate ~ (2,1,24), neon >> that.
  // Keep plate+logo, drop outer canvas and soft halo crumbs.
  const canvasMax = 16;

  var minX = width;
  var minY = height;
  var maxX = 0;
  var maxY = 0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = source.getPixel(x, y);
      final maxC = math.max(p.r, math.max(p.g, p.b));
      if (maxC <= canvasMax) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  // Trim soft outer glow around the tile.
  const inset = 10;
  minX = (minX + inset).clamp(0, width - 1);
  minY = (minY + inset).clamp(0, height - 1);
  maxX = (maxX - inset).clamp(0, width - 1);
  maxY = (maxY - inset).clamp(0, height - 1);

  final contentW = maxX - minX + 1;
  final contentH = maxY - minY + 1;
  final side = math.max(contentW, contentH);
  final left = ((minX + maxX - side) / 2).round().clamp(0, width - side);
  final top = ((minY + maxY - side) / 2).round().clamp(0, height - side);

  final tile = img.copyCrop(
    source,
    x: left,
    y: top,
    width: side,
    height: side,
  );

  final out = img.Image(width: side, height: side, numChannels: 4);
  final cx = (side - 1) / 2.0;
  final cy = (side - 1) / 2.0;
  final radius = side / 2.0;
  const n = 4.8;

  for (var y = 0; y < side; y++) {
    for (var x = 0; x < side; x++) {
      final nx = ((x - cx) / radius).abs();
      final ny = ((y - cy) / radius).abs();
      final d = math.pow(nx, n) + math.pow(ny, n);

      if (d >= 1.0) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      final p = tile.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final maxC = math.max(r, math.max(g, b));

      if (maxC <= canvasMax) {
        // Inside mask but still canvas: fill with plate color so no holes.
        out.setPixelRgba(x, y, 8, 6, 20, 255);
        continue;
      }

      var alpha = 255;
      if (d > 0.95) {
        alpha = ((1.0 - d) / 0.05 * 255).round().clamp(0, 255);
      }

      out.setPixelRgba(x, y, r, g, b, alpha);
    }
  }

  File('images/logo.png').writeAsBytesSync(img.encodePng(out));
  stdout.writeln(
    'Clean logo ${out.width}x${out.height} bounds=($minX,$minY)-($maxX,$maxY)',
  );
}
