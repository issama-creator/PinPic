import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  _cleanLupa();
  _cleanPhotos();
}

bool _isNeon(img.Pixel p) {
  final a = p.a.toInt();
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
  final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
  if (a < 18 || maxC < 40) return false;
  return (sat >= 0.16 && maxC >= 65) || (lum >= 65 && maxC >= 95);
}

void _cleanLupa() {
  final source = img.decodeImage(File('images/logo.png').readAsBytesSync());
  if (source == null) {
    stderr.writeln('logo decode failed');
    exit(1);
  }

  final w = source.width;
  final h = source.height;
  final mask = List.generate(h, (_) => List<bool>.filled(w, false));
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      mask[y][x] = _isNeon(source.getPixel(x, y));
    }
  }

  final labels = List.generate(h, (_) => List<int>.filled(w, 0));
  var next = 1;
  final sizes = <int, int>{};
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (!mask[y][x] || labels[y][x] != 0) continue;
      final label = next++;
      var size = 0;
      final q = Queue<(int, int)>()..add((x, y));
      labels[y][x] = label;
      while (q.isNotEmpty) {
        final (cx, cy) = q.removeFirst();
        size++;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = cx + dx;
            final ny = cy + dy;
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
            if (!mask[ny][nx] || labels[ny][nx] != 0) continue;
            labels[ny][nx] = label;
            q.add((nx, ny));
          }
        }
      }
      sizes[label] = size;
    }
  }

  final keep = <int>{};
  sizes.forEach((label, size) {
    if (size >= 200) keep.add(label);
  });

  var best = keep.first;
  var bestSize = -1;
  for (final e in sizes.entries) {
    if (keep.contains(e.key) && e.value > bestSize) {
      bestSize = e.value;
      best = e.key;
    }
  }

  var sumX = 0.0, sumY = 0.0, n = 0;
  for (var y = 0; y < (h * 0.58).round(); y++) {
    for (var x = 0; x < w; x++) {
      if (labels[y][x] != best) continue;
      sumX += x;
      sumY += y;
      n++;
    }
  }
  final cx = sumX / n;
  final cy = sumY / n;

  final inners = <double>[];
  for (var i = 0; i < 120; i++) {
    final angle = -math.pi * 0.85 + (i / 119) * math.pi * 1.7;
    if (angle > 0.7 && angle < 2.4) continue;
    final runs = <(double, double)>[];
    double? start;
    for (var r = 1.0; r < h * 0.42; r += 1) {
      final x = (cx + math.cos(angle) * r).round();
      final y = (cy + math.sin(angle) * r).round();
      if (x < 0 || y < 0 || x >= w || y >= h) break;
      final on = keep.contains(labels[y][x]);
      if (on) {
        start ??= r;
      } else if (start != null) {
        runs.add((start, r - 1));
        start = null;
      }
    }
    if (start != null) runs.add((start, h * 0.42));
    if (runs.isEmpty) continue;
    final ring = runs.last;
    if (ring.$2 - ring.$1 >= 10) inners.add(ring.$1);
  }
  inners.sort();
  final ringInner = inners[inners.length ~/ 2] + 10;

  final out = img.Image(width: w, height: h, numChannels: 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (!keep.contains(labels[y][x])) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      final p = source.getPixel(x, y);
      var r = p.r.toInt();
      var g = p.g.toInt();
      var b = p.b.toInt();
      var a = p.a.toInt();
      final maxC = math.max(r, math.max(g, b));
      final dist = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));

      // Strip soft glow / hairline crumbs around the mark.
      if (maxC < 85 && a < 200) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      // Quiet the inner landscape so edge lines disappear into the glass.
      if (dist < ringInner) {
        const darken = 0.32;
        r = (r * darken).round().clamp(0, 255);
        g = (g * darken).round().clamp(0, 255);
        b = (b * darken).round().clamp(0, 255);
        a = (a * 0.85).round();
      }

      out.setPixelRgba(x, y, r, g, b, a);
    }
  }

  final cropped = _cropAlpha(out, pad: 16);
  File('images/bgcunb/privacy_logo_lupa.png')
      .writeAsBytesSync(img.encodePng(cropped));
  stdout.writeln('lupa ${cropped.width}x${cropped.height}');
}

void _cleanPhotos() {
  // Prefer original artwork for a clean Photos crop.
  final candidates = [
    'images/bgcunb/b51e00fc-7119-4937-9bf6-4fa38dc9499d.png',
    'images/bgcunb/onboarding_privacy_hero.png',
  ];

  img.Image? source;
  for (final path in candidates) {
    final f = File(path);
    if (!f.existsSync()) continue;
    source = img.decodeImage(f.readAsBytesSync());
    if (source != null) {
      stdout.writeln('photos source: $path');
      break;
    }
  }
  if (source == null) {
    stderr.writeln('photos source missing');
    exit(1);
  }

  final w = source.width;
  final h = source.height;

  var minX = w, minY = h, maxX = 0, maxY = 0;
  var found = false;
  for (var y = 0; y < h; y++) {
    for (var x = (w * 0.5).round(); x < w; x++) {
      final p = source.getPixel(x, y);
      if (p.a < 180) continue;
      if (p.r > 215 && p.g > 215 && p.b > 215) {
        found = true;
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }
  }
  if (!found) {
    stderr.writeln('photos white plate not found');
    exit(1);
  }

  final cx = (minX + maxX) / 2.0;
  final cy = (minY + maxY) / 2.0;
  final side = math.max(maxX - minX, maxY - minY) + 24;
  minX = (cx - side / 2).round().clamp(0, w - 1);
  maxX = (cx + side / 2).round().clamp(0, w - 1);
  minY = (cy - side / 2).round().clamp(0, h - 1);
  maxY = (cy + side / 2).round().clamp(0, h - 1);

  var crop = img.copyCrop(
    source,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );

  // Make near-black outside the squircle transparent; keep icon intact.
  final localCx = crop.width / 2;
  final localCy = crop.height / 2;
  final radius = math.min(crop.width, crop.height) * 0.48;
  for (var y = 0; y < crop.height; y++) {
    for (var x = 0; x < crop.width; x++) {
      final p = crop.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final maxC = math.max(r, math.max(g, b));
      final dx = (x - localCx) / radius;
      final dy = (y - localCy) / radius;
      // Squircle-ish distance.
      final d = math.pow(dx.abs(), 4) + math.pow(dy.abs(), 4);
      if (d > 1.05 || maxC < 25) {
        crop.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  crop = _cropAlpha(crop, pad: 4);
  File('images/bgcunb/privacy_photos.png').writeAsBytesSync(img.encodePng(crop));
  stdout.writeln('photos ${crop.width}x${crop.height}');
}

img.Image _cropAlpha(img.Image src, {int pad = 12}) {
  var minX = src.width, minY = src.height, maxX = 0, maxY = 0;
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      if (src.getPixel(x, y).a == 0) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }
  minX = (minX - pad).clamp(0, src.width - 1);
  minY = (minY - pad).clamp(0, src.height - 1);
  maxX = (maxX + pad).clamp(0, src.width - 1);
  maxY = (maxY + pad).clamp(0, src.height - 1);
  return img.copyCrop(
    src,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
}
