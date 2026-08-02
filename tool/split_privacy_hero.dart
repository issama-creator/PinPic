import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

bool _opaque(img.Pixel p) => p.a > 24;

bool _isLineish(img.Pixel p, int y, int minY, int maxY) {
  final mid = (minY + maxY) / 2;
  final nearMid = (y - mid).abs() < (maxY - minY) * 0.12;
  if (!nearMid) return false;
  final maxC = math.max(p.r, math.max(p.g, p.b));
  final minC = math.min(p.r, math.min(p.g, p.b));
  // Gradient line / dots: saturated but thin band.
  return maxC > 60 && (maxC - minC) > 20;
}

bool _isPhotosWhite(img.Pixel p) {
  return p.a > 200 && p.r > 210 && p.g > 210 && p.b > 210;
}

void main() {
  final src = img.decodeImage(
    File('images/bgcunb/onboarding_privacy_hero.png').readAsBytesSync(),
  );
  if (src == null) {
    stderr.writeln('Failed to decode hero');
    exit(1);
  }

  // Content bounds.
  var minY = src.height;
  var maxY = 0;
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      if (!_opaque(src.getPixel(x, y))) continue;
      minY = math.min(minY, y);
      maxY = math.max(maxY, y);
    }
  }

  // Photos: white squircle on the right.
  var photosMinX = src.width;
  var photosMaxX = 0;
  var photosMinY = src.height;
  var photosMaxY = 0;
  for (var y = 0; y < src.height; y++) {
    for (var x = (src.width * 0.55).round(); x < src.width; x++) {
      final p = src.getPixel(x, y);
      if (!_isPhotosWhite(p) && !_opaque(p)) continue;
      // Prefer white body, but keep petals nearby once we have a seed.
      if (_isPhotosWhite(p) ||
          (photosMaxX > 0 &&
              x >= photosMinX - 4 &&
              x <= photosMaxX + 4 &&
              y >= photosMinY - 4 &&
              y <= photosMaxY + 4 &&
              _opaque(p))) {
        photosMinX = math.min(photosMinX, x);
        photosMaxX = math.max(photosMaxX, x);
        photosMinY = math.min(photosMinY, y);
        photosMaxY = math.max(photosMaxY, y);
      }
    }
  }

  // Expand photos box to full icon once seed found.
  if (photosMaxX > photosMinX) {
    final cx = (photosMinX + photosMaxX) / 2;
    final cy = (photosMinY + photosMaxY) / 2;
    final side = math.max(photosMaxX - photosMinX, photosMaxY - photosMinY) + 18;
    photosMinX = (cx - side / 2).round().clamp(0, src.width - 1);
    photosMaxX = (cx + side / 2).round().clamp(0, src.width - 1);
    photosMinY = (cy - side / 2).round().clamp(0, src.height - 1);
    photosMaxY = (cy + side / 2).round().clamp(0, src.height - 1);
  }

  // Lupa: left content excluding line band and photos.
  var lupaMinX = src.width;
  var lupaMaxX = 0;
  var lupaMinY = src.height;
  var lupaMaxY = 0;
  final cutX = photosMinX - 12;
  for (var y = minY; y <= maxY; y++) {
    for (var x = 0; x < cutX; x++) {
      final p = src.getPixel(x, y);
      if (!_opaque(p)) continue;
      if (_isLineish(p, y, minY, maxY) && x > src.width * 0.22) continue;
      lupaMinX = math.min(lupaMinX, x);
      lupaMaxX = math.max(lupaMaxX, x);
      lupaMinY = math.min(lupaMinY, y);
      lupaMaxY = math.max(lupaMaxY, y);
    }
  }

  const pad = 6;
  img.Image cropBox(int x0, int y0, int x1, int y1) {
    final x = (x0 - pad).clamp(0, src.width - 1);
    final y = (y0 - pad).clamp(0, src.height - 1);
    final w = (x1 - x0 + 2 * pad).clamp(1, src.width - x);
    final h = (y1 - y0 + 2 * pad).clamp(1, src.height - y);
    final cropped = img.copyCrop(src, x: x, y: y, width: w, height: h);
    // Punch transparent any leftover thin connector.
    for (var yy = 0; yy < cropped.height; yy++) {
      for (var xx = 0; xx < cropped.width; xx++) {
        final p = cropped.getPixel(xx, yy);
        final absY = y + yy;
        final absX = x + xx;
        if (absX > src.width * 0.25 &&
            absX < photosMinX - 8 &&
            _isLineish(p, absY, minY, maxY)) {
          cropped.setPixelRgba(xx, yy, 0, 0, 0, 0);
        }
      }
    }
    return cropped;
  }

  final lupa = cropBox(lupaMinX, lupaMinY, lupaMaxX, lupaMaxY);
  final photos = cropBox(photosMinX, photosMinY, photosMaxX, photosMaxY);

  // Make near-black bg transparent.
  void cleanBg(img.Image im) {
    for (var y = 0; y < im.height; y++) {
      for (var x = 0; x < im.width; x++) {
        final p = im.getPixel(x, y);
        final maxC = math.max(p.r, math.max(p.g, p.b));
        if (p.a < 10 || maxC < 18) {
          im.setPixelRgba(x, y, 0, 0, 0, 0);
        }
      }
    }
  }

  cleanBg(lupa);
  cleanBg(photos);

  File('images/bgcunb/privacy_lupa.png').writeAsBytesSync(img.encodePng(lupa));
  File('images/bgcunb/privacy_photos.png')
      .writeAsBytesSync(img.encodePng(photos));
  stdout.writeln(
    'lupa ${lupa.width}x${lupa.height}, photos ${photos.width}x${photos.height}',
  );
}
