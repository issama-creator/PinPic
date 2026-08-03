import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/memory_sample_hint.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

void main() {
  PhotoEntity photo({
    required String id,
    String? title,
    String? body,
    String? category,
    String? ocr,
    String? qr,
    List<String> entityTokens = const [],
  }) {
    return PhotoEntity.create(
      mediaId: id,
      path: '/$id.jpg',
      hash: id,
      width: 10,
      height: 10,
      sizeBytes: 1,
      indexedAt: DateTime(2026, 8, 3),
      category: category,
      cardTitle: title,
      cardBody: body,
      ocrText: ocr,
      qrPayload: qr,
      entityTokens: entityTokens,
      hasQr: qr != null,
    );
  }

  test('prefers brand + amount from indexed card', () {
    final hint = buildSampleMemoryHint([
      photo(
        id: '1',
        title: 'IKEA',
        body: '4 990 ₽',
        category: CategoryEngine.receipts,
        entityTokens: const ['4990', 'ikea'],
        ocr: 'IKEA Total 4990 ₽',
      ),
    ]);
    expect(hint, 'IKEA 4990');
  });

  test('avoids Пароли 2026 year mashup', () {
    final hint = buildSampleMemoryHint([
      photo(
        id: '2',
        title: 'Пароли 2026',
        category: CategoryEngine.passwords,
        entityTokens: const ['2026'],
        ocr: 'Wi-Fi Password: secret99',
      ),
    ]);
    expect(hint, 'вайфай');
    expect(hint, isNot(contains('2026')));
  });

  test('falls back to short password query', () {
    final hint = buildSampleMemoryHint([
      photo(id: '3', category: CategoryEngine.passports),
    ]);
    expect(hint, 'паспорт');
  });

  test('uses wikipedia label from QR', () {
    final hint = buildSampleMemoryHint([
      photo(
        id: '4',
        category: CategoryEngine.qr,
        qr: 'http://en.m.wikipedia.org',
      ),
    ]);
    expect(hint, 'Wikipedia');
  });
}
