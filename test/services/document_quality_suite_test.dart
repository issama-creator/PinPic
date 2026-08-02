import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_summary_service.dart';
import 'package:pinpic/services/fuzzy_matcher.dart';
import 'package:pinpic/services/keyword_engine.dart';
import 'package:pinpic/services/ranking_engine.dart';
import 'package:pinpic/services/synonym_engine.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

void main() {
  final categories = CategoryEngine();
  final keywords = KeywordEngine();
  final synonyms = SynonymEngine();
  final ranking = RankingEngine(fuzzyMatcher: FuzzyMatcher());

  PhotoEntity photo({
    required String id,
    String? ocr,
    List<String> objects = const [],
    String? category,
  }) {
    final builtKeywords = keywords.build(
      ocrText: ocr,
      objects: objects,
      category: category,
      displayName: id,
    );
    return PhotoEntity.create(
      mediaId: id,
      path: '/$id.jpg',
      hash: id,
      width: 100,
      height: 100,
      sizeBytes: 10,
      indexedAt: DateTime(2026, 8, 2),
      displayName: id,
      ocrText: ocr,
      ocrKeywords: keywords.tokenize(ocr),
      objects: objects,
      category: category,
      keywords: builtKeywords,
    );
  }

  RankResult rank(PhotoEntity entity, String query) {
    final tokens = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toSet();
    return ranking.rank(
      photo: entity,
      normalizedQuery: query.toLowerCase(),
      originalTokens: tokens,
      expandedTokens: synonyms.expand(tokens),
    );
  }

  group('document quality suite', () {
    test('ticket text finds both билет and концерт', () {
      final ticket = photo(
        id: 'ticket',
        ocr: 'БИЛЕТ НА КОНЦЕРТ 123456',
        category: CategoryEngine.tickets,
      );

      expect(categories.classify(ocrText: ticket.ocrText, objects: const [], hasQr: false), CategoryEngine.tickets);
      expect(rank(ticket, 'билет').score, greaterThanOrEqualTo(95));
      expect(rank(ticket, 'концерт').score, greaterThanOrEqualTo(95));
      expect(
        rank(ticket, 'билет').evidence.any((e) => e.contains('OCR') || e.contains('билет')),
        isTrue,
      );
    });

    test('passport and receipt stay in their own categories under документ umbrella', () {
      expect(
        CategoryEngine.inferCategoriesFromTokens(const ['документ']),
        containsAll([
          CategoryEngine.tickets,
          CategoryEngine.passports,
          CategoryEngine.licenses,
          CategoryEngine.contracts,
          CategoryEngine.warranties,
          CategoryEngine.prescriptions,
          CategoryEngine.receipts,
        ]),
      );
      expect(
        categories.classify(
          ocrText: 'ПАСПОРТ ATLASOV',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.passports,
      );
      expect(
        categories.classify(
          ocrText: 'Водительское удостоверение',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.licenses,
      );
      expect(
        categories.classify(
          ocrText: 'Гарантийный талон LG',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.warranties,
      );
      expect(
        categories.classify(
          ocrText: 'Рецепт аптека лекарство',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.prescriptions,
      );
      expect(
        categories.classify(
          ocrText: 'IKEA Receipt Total 4990',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.receipts,
      );
    });

    test('local summary extracts brand amount and date cues', () {
      final summary = DocumentSummaryService().build(
        ocrText: 'IKEA Receipt Total 4 990 ₽\n15.07.2025',
        category: CategoryEngine.receipts,
      );
      expect(summary, isNotNull);
      expect(summary!.toLowerCase(), contains('ikea'));
      expect(summary, contains('₽'));
    });

    test('typo паспрот still ranks a passport keyword photo', () {
      final passport = photo(
        id: 'passport',
        ocr: 'ПАСПОРТ RUSSIAN FEDERATION',
        category: CategoryEngine.passports,
      );
      final result = ranking.rank(
        photo: passport,
        normalizedQuery: 'паспрот',
        originalTokens: {'паспрот'},
        expandedTokens: {'паспрот'},
        similarFallback: true,
      );
      expect(result.score, greaterThan(8));
      expect(result.reason.toLowerCase(), contains('паспорт'));
    });

    test('wifi password screenshot is searchable by пароль', () {
      final wifi = photo(
        id: 'wifi',
        ocr: 'WiFi Password 12345678',
        category: CategoryEngine.passwords,
      );
      final result = rank(wifi, 'пароль');
      expect(result.score, greaterThanOrEqualTo(70));
    });

    test('semantic-only noise is weaker than exact OCR document hit', () {
      final ticket = photo(
        id: 'ticket',
        ocr: 'БИЛЕТ НА КОНЦЕРТ',
        category: CategoryEngine.tickets,
      );
      final exact = rank(ticket, 'билет');
      final semantic = ranking.rank(
        photo: photo(id: 'camera'),
        normalizedQuery: 'билет',
        originalTokens: {'билет'},
        expandedTokens: {'билет'},
        semanticSimilarity: 0.4,
      );
      expect(exact.score, greaterThan(semantic.score));
      expect(semantic.isSimilar, isTrue);
    });
  });
}
