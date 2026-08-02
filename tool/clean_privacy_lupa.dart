import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  // Fresh crop from the composed hero, then strip aura.
  final src = img.decodeImage(
    File('images/bgcunb/onboarding_privacy_hero.png').readAsBytesSync(),
  );
  if (src == null) {
    stderr.writeln('Failed to decode hero');
    exit(1);
  }

  // Approximate lupa region on left half.
  final regionW = (src.width * 0.42).round();
  var minX = regionW;
  var maxX = 0;
  var minY = src.height;
  var maxY = 0;

  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < regionW; x++) {
      final p = src.getPixel(x, y);
      if (!_isSolidStroke(p)) continue;
      minX = math.min(minX, x);
      maxX = math.max(maxX, x);
      minY = math.min(minY, y);
      maxY = math.max(maxY, y);
    }
  }

  const pad = 8;
  minX = (minX - pad).clamp(0, src.width - 1);
  maxX = (maxX + pad).clamp(0, src.width - 1);
  minY = (minY - pad).clamp(0, src.height - 1);
  maxY = (maxY + pad).clamp(0, src.height - 1);

  final w = maxX - minX + 1;
  final h = maxY - minY + 1;
  final out = img.Image(width: w, height: h, numChannels: 4);

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = src.getPixel(minX + x, minY + y);
      if (_isSolidStroke(p)) {
        out.setPixelRgba(
          x,
          y,
          p.r.toInt(),
          p.g.toInt(),
          p.b.toInt(),
          p.a.toInt(),
        );
      } else {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  File('images/bgcunb/privacy_lupa.png').writeAsBytesSync(img.encodePng(out));
  stdout.writeln('Clean lupa ${out.width}x${out.height}');
}

bool _isSolidStroke(img.Pixel p) {
  final a = p.a.toInt();
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  final sat = maxC - minC;

  // Keep only opaque, bright, saturated stroke pixels.
  // Soft purple/blue aura is semi-transparent and lower contrast.
  if (a < 200) return false;
  if (maxC < 90) return false;
  if (sat < 35 && maxC < 180) return false;
  return true;
}
