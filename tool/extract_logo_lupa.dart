import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Full lupa/"P" mark, glass emptied. No stem/handle geometry hacks.
void main() {
  final source = img.decodeImage(File('images/logo.png').readAsBytesSync());
  if (source == null) {
    stderr.writeln('Failed to decode logo');
    exit(1);
  }

  final w = source.width;
  final h = source.height;

  bool isNeon(img.Pixel p) {
    final a = p.a.toInt();
    final r = p.r.toInt();
    final g = p.g.toInt();
    final b = p.b.toInt();
    final maxC = math.max(r, math.max(g, b));
    final minC = math.min(r, math.min(g, b));
    final sat = maxC == 0 ? 0.0 : (maxC - minC) / maxC;
    final lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    if (a < 20 || maxC < 50) return false;
    return (sat >= 0.18 && maxC >= 75) || (lum >= 75 && maxC >= 110);
  }

  final mask = List.generate(h, (_) => List<bool>.filled(w, false));
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      mask[y][x] = isNeon(source.getPixel(x, y));
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
        final (cx0, cy0) = q.removeFirst();
        size++;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = cx0 + dx;
            final ny = cy0 + dy;
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

  var best = 1;
  var bestSize = -1;
  sizes.forEach((label, size) {
    if (size > bestSize) {
      bestSize = size;
      best = label;
    }
  });

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
  for (var i = 0; i < 180; i++) {
    final angle = i * math.pi * 2 / 180;
    if (angle > 0.75 && angle < 2.45) continue;
    final runs = <(double, double)>[];
    double? start;
    for (var r = 1.0; r < h * 0.45; r += 1) {
      final x = (cx + math.cos(angle) * r).round();
      final y = (cy + math.sin(angle) * r).round();
      if (x < 0 || y < 0 || x >= w || y >= h) break;
      final on = labels[y][x] == best;
      if (on) {
        start ??= r;
      } else if (start != null) {
        runs.add((start, r - 1));
        start = null;
      }
    }
    if (start != null) runs.add((start, h * 0.45));
    if (runs.isEmpty) continue;
    final ring = runs.last;
    if (ring.$2 - ring.$1 >= 12) inners.add(ring.$1);
  }
  inners.sort();
  // Base hollow; extra clearance only in the lower half where landscape sits.
  final clearR = inners[inners.length ~/ 2] + 12;

  stdout.writeln(
    'clearR=${clearR.toStringAsFixed(1)} samples=${inners.length}',
  );

  final out = img.Image(width: w, height: h, numChannels: 4);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (labels[y][x] != best) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      final dx = x - cx;
      final dy = y - cy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final limit = dy > 0 ? clearR + 28 : clearR;
      if (dist < limit) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }

      final p = source.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final a = p.a.toInt();
      final maxC = math.max(r, math.max(g, b));
      if (maxC < 90 && a < 210) {
        out.setPixelRgba(x, y, 0, 0, 0, 0);
        continue;
      }
      out.setPixelRgba(x, y, r, g, b, a);
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
  const pad = 20;
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

  File('images/bgcunb/privacy_logo_lupa.png')
      .writeAsBytesSync(img.encodePng(cropped));
  stdout.writeln('Wrote ${cropped.width}x${cropped.height}');
}
