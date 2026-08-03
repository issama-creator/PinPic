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
      entityTokens: entityTokens,
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
      ),
    ]);
    expect(hint, 'IKEA 4990');
  });

  test('falls back to category when no facts', () {
    final hint = buildSampleMemoryHint([
      photo(id: '2', category: CategoryEngine.passports),
    ]);
    expect(hint, CategoryEngine.passports);
  });
}
