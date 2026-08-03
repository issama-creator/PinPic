import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/memory_card_title.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

void main() {
  PhotoEntity photo({
    required String id,
    String? category,
    String? ocr,
    String? custom,
    String? cardTitle,
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
      ocrText: ocr,
      customTitle: custom,
      cardTitle: cardTitle,
    );
  }

  test('password photos get Пароль instead of bare Пароли', () {
    final title = resolveMemoryCardTitle(
      photo(
        id: '1',
        category: CategoryEngine.passwords,
        ocr: 'pR!Xg788FnA909%!',
        cardTitle: 'Пароли',
      ),
    );
    expect(title, 'Пароль');
  });

  test('custom title wins', () {
    final title = resolveMemoryCardTitle(
      photo(
        id: '2',
        category: CategoryEngine.passwords,
        custom: 'Wi‑Fi у бабушки',
      ),
    );
    expect(title, 'Wi‑Fi у бабушки');
  });
}
