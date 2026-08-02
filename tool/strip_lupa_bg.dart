import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final path = 'images/bgcunb/lupa.png';
  final srcFile = File(path);
  if (!srcFile.existsSync()) {
    stderr.writeln('Missing $path');
    exit(1);
  }

  // Always backup once from whatever is currently on disk if no backup.
  final backup = File('images/bgcunb/lupa_with_bg.png');
  if (!backup.existsSync()) {
    srcFile.copySync(backup.path);
  }

  // Process the CURRENT file (user may have replaced it).
  final source = img.decodeImage(srcFile.readAsBytesSync());
  if (source == null) {
    stderr.writeln('Failed to decode');
    exit(1);
  }

  final w = source.width;
  final h = source.height;
  stdout.writeln('input ${w}x$h');

  bool isCheckerOrPlate(int r, int g, int b) {
    final maxC = math.max(r, math.max(g, b));
    final minC = math.min(r, math.min(g, b));
    final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
    final delta = maxC - minC;
    // Gray checker tiles / dark plate — any luminance.
    return sat < 0.16 && delta < 32;
  }

  bool isIcon(int r, int g, int b, int a) {
    if (a < 8) return false;
    if (isCheckerOrPlate(r, g, b)) return false;

    final maxC = math.max(r, math.max(g, b));
    final minC = math.min(r, math.min(g, b));
    final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
    final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;

    // Purple / blue neon body.
    if (sat >= 0.16 && maxC >= 60 && (b >= 55 || r >= 65)) return true;
    // Soft landscape fill.
    if (sat >= 0.10 && maxC >= 70 && (b + r) > g * 1.3) return true;
    // Bright rim.
    if (lum >= 150 && sat >= 0.06 && maxC >= 150) return true;
    return false;
  }

  final out = img.Image(width: w, height: h, numChannels: 4);
  var kept = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = source.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final a = p.a.toInt();
      if (!isIcon(r, g, b, a)) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      } else {
        out.setPixelRgba(x, y, r, g, b, 255);
        kept++;
      }
    }
  }

  var minX = w, minY = h, maxX = 0, maxY = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (out.getPixel(x, y).a == 0) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  if (kept < 100) {
    stderr.writeln('Almost nothing kept ($kept) — abort');
    exit(1);
  }

  const pad = 12;
  minX = (minX - pad).clamp(0, w - 1);
  minY = (minY - pad).clamp(0, h - 1);
  maxX = (maxX + pad).clamp(0, w - 1);
  maxY = (maxY + pad).clamp(0, h - 1);

  final cropped = img.copyCrop(
    out,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );

  File(path).writeAsBytesSync(img.encodePng(cropped));
  // Also sync the asset the diagram used before.
  File('images/bgcunb/privacy_logo_lupa.png')
      .writeAsBytesSync(img.encodePng(cropped));

  stdout.writeln(
    'stripped → ${cropped.width}x${cropped.height} kept=$kept',
  );
}
