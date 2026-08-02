import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final logo = img.decodeImage(File('images/logo.png').readAsBytesSync())!;
  final preview = img.Image(
    width: logo.width,
    height: logo.height,
    numChannels: 4,
  );

  // Checkerboard so transparency is obvious.
  const cell = 32;
  for (var y = 0; y < preview.height; y++) {
    for (var x = 0; x < preview.width; x++) {
      final light = ((x ~/ cell) + (y ~/ cell)).isEven;
      final c = light ? 220 : 180;
      preview.setPixelRgba(x, y, c, c, c, 255);
    }
  }

  img.compositeImage(preview, logo);
  File('images/logo_preview.png').writeAsBytesSync(img.encodePng(preview));
  stdout.writeln('Wrote images/logo_preview.png');
}
