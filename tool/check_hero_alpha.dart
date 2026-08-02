import "dart:io";
import "package:image/image.dart" as img;
void main() {
  final i = img.decodeImage(File("images/bgcunb/onboarding_privacy_hero.png").readAsBytesSync())!;
  var t=0, dark=0, opaque=0;
  for (final p in i) {
    if (p.a == 0) { t++; continue; }
    opaque++;
    final maxC = [p.r, p.g, p.b].reduce((a,b)=>a>b?a:b);
    if (maxC < 40) dark++;
  }
  final c = i.getPixel(0,0);
  final m = i.getPixel(i.width~/2, i.height~/2);
  print("size=${i.width}x${i.height} transparent=$t opaque=$opaque darkOpaque=$dark");
  print("corner=${c.r},${c.g},${c.b},${c.a} mid=${m.r},${m.g},${m.b},${m.a}");
}
