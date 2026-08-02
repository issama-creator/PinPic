import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final original = File('images/logo_original.png');
  if (!original.existsSync()) {
    File('images/logo.png').copySync('images/logo_original.png');
  }

  final source = img.decodeImage(original.readAsBytesSync());
  if (source == null) {
    stderr.writeln('Failed to decode logo');
    exit(1);
  }

  final width = source.width;
  final height = source.height;
  final out = img.Image(width: width, height: height, numChannels: 4);

  double logoScore(int r, int g, int b) {
    final maxC = math.max(r, math.max(g, b)).toDouble();
    final minC = math.min(r, math.min(g, b)).toDouble();
    final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
    final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;

    var score = 0.0;
    if (sat > 0.28 && maxC > 90) score += sat * maxC;
    if (r > 100 && b > 100 && g < r && g < b) score += 50;
    if (b > 110 && b > r && b > g) score += 45;
    if (lum > 110 && sat > 0.18) score += 30;
    if (b >= 50 && sat > 0.25 && maxC >= 55 && lum < 130) score += 40;
    return score;
  }

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final p = source.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final score = logoScore(r, g, b);

      if (score >= 35) {
        out.setPixelRgba(x, y, r, g, b, 255);
      } else {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  var minX = width;
  var minY = height;
  var maxX = 0;
  var maxY = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (out.getPixel(x, y).a == 0) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  const pad = 16;
  minX = math.max(0, minX - pad);
  minY = math.max(0, minY - pad);
  maxX = math.min(width - 1, maxX + pad);
  maxY = math.min(height - 1, maxY + pad);

  final cropped = img.copyCrop(
    out,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );

  File('images/logo.png').writeAsBytesSync(img.encodePng(cropped));

  // Checkerboard preview for visual QA
  final preview = img.Image(
    width: cropped.width,
    height: cropped.height,
    numChannels: 4,
  );
  const cell = 28;
  for (var y = 0; y < preview.height; y++) {
    for (var x = 0; x < preview.width; x++) {
      final light = ((x ~/ cell) + (y ~/ cell)).isEven;
      final c = light ? 230 : 190;
      preview.setPixelRgba(x, y, c, c, c, 255);
    }
  }
  img.compositeImage(preview, cropped);
  File('images/logo_preview.png').writeAsBytesSync(img.encodePng(preview));

  stdout.writeln(
    'Transparent cropped logo: ${cropped.width}x${cropped.height}',
  );
}
