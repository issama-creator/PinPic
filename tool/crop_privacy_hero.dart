import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final source = img.decodeImage(
    File('images/bgcunb/b51e00fc-7119-4937-9bf6-4fa38dc9499d.png')
        .readAsBytesSync(),
  );
  if (source == null) {
    stderr.writeln('Failed to decode privacy artwork');
    exit(1);
  }

  final width = source.width;
  final height = source.height;
  final scanTop = (height * 0.08).round();
  final scanBottom = (height * 0.38).round();

  final rowScore = List<int>.filled(height, 0);
  for (var y = scanTop; y < scanBottom; y++) {
    var score = 0;
    for (var x = 0; x < width; x++) {
      final p = source.getPixel(x, y);
      final maxC = math.max(p.r, math.max(p.g, p.b));
      if (maxC > 70) score++;
    }
    rowScore[y] = score;
  }

  var bestY = scanTop;
  var bestScore = -1;
  for (var y = scanTop; y < scanBottom; y++) {
    if (rowScore[y] > bestScore) {
      bestScore = rowScore[y];
      bestY = y;
    }
  }

  var minY = bestY;
  var maxY = bestY;
  final threshold = (bestScore * 0.18).round().clamp(8, 999999);
  while (minY > scanTop && rowScore[minY] >= threshold) {
    minY--;
  }
  while (maxY < scanBottom - 1 && rowScore[maxY] >= threshold) {
    maxY++;
  }

  var minX = width;
  var maxX = 0;
  for (var y = minY; y <= maxY; y++) {
    for (var x = 0; x < width; x++) {
      final p = source.getPixel(x, y);
      if (_isKeepPixel(p.r.toInt(), p.g.toInt(), p.b.toInt())) {
        minX = math.min(minX, x);
        maxX = math.max(maxX, x);
      }
    }
  }

  const padX = 24;
  const padY = 28;
  minX = (minX - padX).clamp(0, width - 1);
  maxX = (maxX + padX).clamp(0, width - 1);
  minY = (minY - padY).clamp(0, height - 1);
  maxY = (maxY + padY).clamp(0, height - 1);

  final cropW = maxX - minX + 1;
  final cropH = maxY - minY + 1;
  final cropped = img.copyCrop(
    source,
    x: minX,
    y: minY,
    width: cropW,
    height: cropH,
  );

  final out = img.Image(width: cropW, height: cropH, numChannels: 4);
  var kept = 0;
  for (var y = 0; y < cropH; y++) {
    for (var x = 0; x < cropW; x++) {
      final p = cropped.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();

      if (!_isKeepPixel(r, g, b)) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      // Soften very dark glow fringe.
      final maxC = math.max(r, math.max(g, b));
      final alpha = maxC < 70 ? ((maxC - 40) / 30 * 255).round().clamp(0, 255) : 255;
      out.setPixelRgba(x, y, r, g, b, alpha);
      kept++;
    }
  }

  File('images/bgcunb/onboarding_privacy_hero.png').writeAsBytesSync(
    img.encodePng(out),
  );
  stdout.writeln('Clean hero ${cropW}x$cropH kept=$kept');
}

bool _isKeepPixel(int r, int g, int b) {
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;

  // Photos app icon (bright / multi-color).
  if (maxC >= 140 && sat >= 0.15) return true;
  if (r > 180 && g > 180 && b > 180) return true;

  // Neon purple / blue glow of lupa and line.
  if (maxC >= 70 && sat >= 0.28 && (b >= 70 || r >= 70)) return true;
  if (b >= 100 && sat >= 0.2 && maxC >= 90) return true;
  if (r >= 90 && b >= 110 && sat >= 0.25) return true;

  return false;
}
