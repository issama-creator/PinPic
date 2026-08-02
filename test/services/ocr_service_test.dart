import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/ocr_service.dart';

void main() {
  final ocr = OcrService();

  test('pickRicherText prefers denser Cyrillic deep pass', () {
    const fast = 'BNEET HA KOHUEPT';
    const deep = 'БИЛЕТ НА КОНЦЕРТ 123456';
    expect(ocr.pickRicherText(fast, deep), deep);
  });

  test('scoreText rewards Cyrillic content', () {
    expect(
      OcrService.scoreText('БИЛЕТ НА КОНЦЕРТ'),
      greaterThan(OcrService.scoreText('BNEET')),
    );
  });

  test('needsDeepText stays true for short or non-document Latin', () {
    expect(ocr.needsDeepText(null), isTrue);
    expect(ocr.needsDeepText('abc'), isTrue);
    expect(ocr.needsDeepText('IKEA receipt total paid'), isFalse);
  });
}
