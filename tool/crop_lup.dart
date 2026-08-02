import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  final path = 'images/bgcunb/lup.png';
  final src = img.decodeImage(File(path).readAsBytesSync());
  if (src == null) {
    stderr.writeln('decode failed');
    exit(1);
  }

  var minX = src.width, minY = src.height, maxX = 0, maxY = 0;
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      if (src.getPixel(x, y).a < 16) continue;
      minX = math.min(minX, x);
      minY = math.min(minY, y);
      maxX = math.max(maxX, x);
      maxY = math.max(maxY, y);
    }
  }

  const pad = 8;
  minX = (minX - pad).clamp(0, src.width - 1);
  minY = (minY - pad).clamp(0, src.height - 1);
  maxX = (maxX + pad).clamp(0, src.width - 1);
  maxY = (maxY + pad).clamp(0, src.height - 1);

  final cropped = img.copyCrop(
    src,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );

  File(path).writeAsBytesSync(img.encodePng(cropped));
  stdout.writeln(
    'cropped ${src.width}x${src.height} → ${cropped.width}x${cropped.height}',
  );
}
