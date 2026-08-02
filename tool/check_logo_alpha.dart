import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final image = img.decodeImage(File('images/logo.png').readAsBytesSync())!;
  final samples = [
    [0, 0],
    [8, 8],
    [image.width - 1, 0],
    [0, image.height - 1],
    [image.width ~/ 2, image.height ~/ 2],
    [image.width ~/ 2, image.height ~/ 3],
  ];

  stdout.writeln('size=${image.width}x${image.height}');
  for (final s in samples) {
    final p = image.getPixel(s[0], s[1]);
    stdout.writeln('(${s[0]},${s[1]}) rgba=${p.r},${p.g},${p.b},${p.a}');
  }
}
