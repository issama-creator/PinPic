import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/fuzzy_matcher.dart';
import 'package:pinpic/services/keyword_engine.dart';
import 'package:pinpic/services/ranking_engine.dart';
import 'package:pinpic/services/synonym_engine.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

void main() {
  group('CategoryEngine', () {
    final engine = CategoryEngine();

    test(
      'does not classify "carving"/"vacation"/"победа" as substring hits',
      () {
        // Regression: a wood-carving label used to match the "car" needle
        // via naive substring search, wrongly tagging the photo as Cars.
        expect(
          engine.classify(
            ocrText: null,
            objects: const ['Carving'],
            hasQr: false,
            displayName: 'rajv89-natural-2453617',
          ),
          isNot(CategoryEngine.cars),
        );
        // "vacation.jpg" must not become Животные via the "cat" substring.
        expect(
          engine.classify(
            ocrText: null,
            objects: const [],
            hasQr: false,
            displayName: 'vacation-trip.jpg',
          ),
          isNot(CategoryEngine.animals),
        );
        // "победа" (victory) must not become Еда via the "еда" substring.
        expect(
          engine.classify(
            ocrText: 'С Победой! Поздравляем',
            objects: const [],
            hasQr: false,
          ),
          isNot(CategoryEngine.food),
        );
      },
    );

    test('still classifies real whole-word object labels', () {
      expect(
        engine.classify(ocrText: null, objects: const ['Car'], hasQr: false),
        CategoryEngine.cars,
      );
      expect(
        engine.classify(ocrText: null, objects: const ['Cat'], hasQr: false),
        CategoryEngine.animals,
      );
      expect(
        engine.classify(ocrText: null, objects: const ['Person'], hasQr: false),
        CategoryEngine.people,
      );
    });

    test('does not turn generic Animal/Wildlife guesses into a category', () {
      expect(
        engine.classify(
          ocrText: null,
          objects: const ['Pencil', 'Sharpener', 'Box', 'Animal', 'Wildlife'],
          hasQr: false,
        ),
        isNot(CategoryEngine.animals),
      );
    });

    test('does not categorize bead pin objects as passwords or plants', () {
      expect(
        engine.classify(
          // Tesseract can hallucinate "tree" in bead texture; image labels
          // must remain the source of broad visual categories.
          ocrText: 'oe ee - res, tree ters, egeore',
          objects: const ['Far', 'Safety', 'Pin', 'Textile', 'Scarf'],
          hasQr: false,
        ),
        isNull,
      );
    });

    test('still matches Russian declensions via safe prefix', () {
      expect(
        engine.classify(
          ocrText: 'Договор аренды документов',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.contracts,
      );
    });

    test('detects passport and ticket as distinct document categories', () {
      expect(
        engine.classify(
          ocrText: 'ПАСПОРТ RUSSIAN FEDERATION',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.passports,
      );
      expect(
        engine.classify(
          ocrText: 'БИЛЕТ НА КОНЦЕРТ 123456',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.tickets,
      );
    });

    test('detects a password/OTP screenshot as Пароли, not Скриншоты', () {
      expect(
        engine.classify(
          ocrText: 'Введите пароль для входа в аккаунт',
          objects: const [],
          hasQr: false,
          mimeType: 'image/png',
        ),
        CategoryEngine.passwords,
      );
      expect(
        engine.classify(
          ocrText: 'Your verification code is 482913',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.passwords,
      );
    });

    test('detects a boarding pass as Билеты rather than QR', () {
      expect(
        engine.classify(
          ocrText: 'Boarding pass Seat 14A Gate B12 Рейс SU100',
          objects: const [],
          hasQr: true,
        ),
        CategoryEngine.tickets,
      );
    });

    test('detects a business card as Визитки rather than Документы', () {
      expect(
        engine.classify(
          ocrText: 'Иванов Иван, менеджер. Визитка компании',
          objects: const [],
          hasQr: false,
        ),
        CategoryEngine.businessCards,
      );
    });

    test('ignores animal-looking tokens in filenames', () {
      // Unsplash author slugs like "theangryteddy-…" must not decide category.
      expect(
        engine.classify(
          ocrText: null,
          objects: const ['Camera'],
          hasQr: false,
          displayName: 'theangryteddy-keyboard-camera.jpg',
        ),
        isNot(CategoryEngine.animals),
      );
      expect(
        engine.classify(
          ocrText: null,
          objects: const [],
          hasQr: false,
          displayName: 'theangryteddy-keyboard-camera.jpg',
        ),
        isNull,
      );
    });

    test('detects a plant/flower photo as Растения', () {
      expect(
        engine.classify(
          ocrText: null,
          objects: const ['Flower', 'Plant'],
          hasQr: false,
        ),
        CategoryEngine.plants,
      );
    });

    test('a receipt with a QR code is still Чеки, not QR', () {
      expect(
        engine.classify(
          ocrText: 'Кассовый чек Итого: 540.00 НДС 20%',
          objects: const [],
          hasQr: true,
        ),
        CategoryEngine.receipts,
      );
    });

    test('a plain QR code with no other content stays QR', () {
      expect(
        engine.classify(ocrText: null, objects: const [], hasQr: true),
        CategoryEngine.qr,
      );
    });

    test('infers category from expanded search tokens', () {
      expect(
        CategoryEngine.inferFromTokens({'билет', 'билеты', 'ticket'}),
        CategoryEngine.tickets,
      );
      expect(
        CategoryEngine.inferFromTokens({'чек', 'чеки', 'receipt'}),
        CategoryEngine.receipts,
      );
      expect(CategoryEngine.inferFromTokens({'лев', 'lion'}), isNull);
    });

    test('uses Документы as a search umbrella without merging categories', () {
      final categories = CategoryEngine.inferCategoriesFromTokens({
        'документ',
        'documents',
      });
      expect(
        categories,
        containsAll([
          CategoryEngine.documents,
          CategoryEngine.receipts,
          CategoryEngine.tickets,
          CategoryEngine.passwords,
          CategoryEngine.businessCards,
        ]),
      );
    });
  });

  group('SynonymEngine', () {
    final engine = SynonymEngine();

    test('expands Russian forms and RU to EN labels', () {
      final expanded = engine.expand({'собаки', 'авто', 'чек'});

      expect(expanded, containsAll(['dog', 'car', 'receipt']));
    });

    test('normalizes Cyrillic OCR consistently', () {
      expect(engine.normalize('  ЁЛКА   ЧЕК  '), 'елка чек');

      final keywords = KeywordEngine().build(
        ocrText: 'ООО Ёлка\nКАССОВЫЙ ЧЕК №123',
        objects: const [],
        category: 'Чеки',
      );
      expect(keywords, containsAll(['елка', 'кассовый', 'чек', 'receipt']));
    });

    test('expands "человек" to English person/face labels and back', () {
      final expanded = engine.expand({'человек'});
      expect(expanded, containsAll(['person', 'people', 'face', 'portrait']));

      final fromEnglish = engine.expand({'person'});
      expect(fromEnglish, containsAll(['человек', 'люди']));
    });

    test('"девушка" bridges to people tokens for search', () {
      final expanded = engine.expand({'девушка'});
      expect(
        expanded,
        containsAll([
          'девушка',
          'woman',
          'girl',
          'человек',
          'люди',
          'person',
          'face',
        ]),
      );

      final keywords = KeywordEngine().build(
        ocrText: null,
        objects: const [],
        category: 'Люди',
      );
      final queryTokens = engine.expand({'девушка'});
      expect(
        keywords.any(queryTokens.contains),
        isTrue,
        reason: 'people-category photos must be findable by "девушка"',
      );
    });

    test('expands "растение" to English plant/flower/tree labels and back', () {
      final expanded = engine.expand({'растение'});
      expect(expanded, containsAll(['plant', 'flower', 'tree']));

      final fromEnglish = engine.expand({'plant'});
      expect(fromEnglish, containsAll(['растение', 'цветок', 'дерево']));
    });

    test(
      'a photo with a detected "Person" object is findable by "человек"',
      () {
        final keywords = KeywordEngine().build(
          ocrText: null,
          objects: const ['Person'],
          category: 'Люди',
        );
        expect(keywords, containsAll(['person', 'человек', 'люди']));
      },
    );

    test('expands "пароль" to English password/login labels and back', () {
      final expanded = engine.expand({'пароль'});
      expect(expanded, containsAll(['password', 'login']));

      final fromEnglish = engine.expand({'password'});
      expect(fromEnglish, containsAll(['пароль', 'пароли']));
    });

    test('bridges child, Wi-Fi and airport intents', () {
      expect(
        engine.expand({'ребенок'}),
        containsAll(['дети', 'сын', 'дочь', 'child']),
      );
      expect(
        engine.expand({'вайфай'}),
        containsAll(['wifi', 'password', 'пароль', 'ssid']),
      );
      expect(
        engine.expand({'аэропорт'}),
        containsAll(['airport', 'самолет', 'plane']),
      );
    });

    test('normalizes IKEA transliteration into a single search intent', () {
      expect(
        engine.expand({'икея'}),
        containsAll(['ikea', 'икеа', 'мебель', 'магазин']),
      );
    });

    test('receipt category injects useful non-OCR search intent', () {
      final keywords = KeywordEngine().build(
        ocrText: 'IKEA 4990',
        objects: const ['Paper'],
        category: CategoryEngine.receipts,
      );
      expect(
        keywords,
        containsAll(['чек', 'квитанция', 'магазин', 'покупка', 'документ']),
      );
    });

    test('covers everyday gallery topics with 5+ synonyms each', () {
      final samples = <String, List<String>>{
        'кофе': ['coffee', 'cappuccino', 'латте'],
        'море': ['sea', 'ocean', 'пляж'],
        'телефон': ['phone', 'smartphone', 'айфон'],
        'ключи': ['key', 'keys', 'замок'],
        'свадьба': ['wedding', 'bride', 'жених'],
        'лекарство': ['medicine', 'pills', 'таблетки'],
        'футболка': ['tshirt', 'tee', 'майка'],
        'концерт': ['concert', 'stage', 'сцена'],
        'паспорт': ['passport', 'удостоверение'],
        'снег': ['snow', 'snowfall', 'сугроб'],
        'тигр': ['tiger', 'tigers', 'тигрёнок'],
        'пицца': ['pizza', 'pepperoni'],
        'йога': ['yoga', 'pilates', 'растяжка'],
        'музей': ['museum', 'gallery', 'выставка'],
        'наушники': ['headphones', 'earbuds', 'airpods'],
      };

      for (final entry in samples.entries) {
        final expanded = engine.expand({entry.key});
        expect(expanded, contains(entry.key), reason: entry.key);
        expect(
          expanded.length,
          greaterThanOrEqualTo(5),
          reason: '${entry.key} should expand to 5+ synonyms',
        );
        for (final expected in entry.value) {
          expect(
            expanded,
            contains(engine.normalize(expected)),
            reason: '${entry.key} → $expected',
          );
        }
      }
    });

    test('has no overlapping tokens across synonym groups', () {
      for (final token in const [
        'карта',
        'кухня',
        'keys',
        'plate',
        'wire',
        'дипломный',
      ]) {
        final expanded = engine.expand({token});
        expect(expanded, contains(token));
      }
    });

    test(
      'a photo with a detected "Plant" object is findable by "растение"',
      () {
        final keywords = KeywordEngine().build(
          ocrText: null,
          objects: const ['Plant'],
          category: null,
        );
        expect(keywords, containsAll(['plant', 'растение', 'цветок']));
      },
    );
  });

  group('FuzzyMatcher', () {
    final matcher = FuzzyMatcher();

    test('handles insertion and transposition typos', () {
      expect(matcher.isMatch('паспор', 'паспорт'), isTrue);
      expect(matcher.isMatch('собка', 'собака'), isTrue);
      expect(matcher.isMatch('докмуент', 'документ'), isTrue);
    });

    test('rejects unsafe short and distant matches', () {
      expect(matcher.isMatch('кот', 'код'), isFalse);
      expect(matcher.isMatch('паспорт', 'машина'), isFalse);
    });
  });

  group('RankingEngine', () {
    final ranking = RankingEngine();

    test('multi-token exact OCR outranks a partial keyword match', () {
      final exact = _photo(
        id: 'exact',
        ocr: 'Кассовый чек магазин продукты',
        keywords: ['кассовый', 'чек', 'магазин', 'продукты'],
      );
      final partial = _photo(id: 'partial', keywords: ['чек']);
      final tokens = {'чек', 'магазин'};

      final exactRank = ranking.rank(
        photo: exact,
        normalizedQuery: 'чек магазин',
        originalTokens: tokens,
        expandedTokens: tokens,
      );
      final partialRank = ranking.rank(
        photo: partial,
        normalizedQuery: 'чек магазин',
        originalTokens: tokens,
        expandedTokens: tokens,
      );

      expect(exactRank.score, greaterThan(partialRank.score));
      expect(exactRank.confidence, greaterThan(partialRank.confidence));
    });

    test('fuzzy match returns a human-readable reason', () {
      final result = ranking.rank(
        photo: _photo(id: 'passport', keywords: ['паспорт']),
        normalizedQuery: 'паспотр',
        originalTokens: {'паспотр'},
        expandedTokens: {'паспотр'},
        similarFallback: true,
      );

      expect(result.score, greaterThan(8));
      expect(result.reason, contains('паспорт'));
    });

    test('semantic-only hit is explicitly marked similar', () {
      final result = ranking.rank(
        photo: _photo(id: 'tower'),
        normalizedQuery: 'париж',
        originalTokens: {'париж'},
        expandedTokens: {'париж'},
        semanticSimilarity: 0.42,
      );

      expect(result.isSimilar, isTrue);
      expect(result.evidence, contains('✓ По смыслу'));
      expect(result.confidence, lessThan(70));
    });

    test('exact OCR exposes the matching evidence', () {
      final result = ranking.rank(
        photo: _photo(
          id: 'ikea',
          ocr: 'IKEA кассовый чек 1540',
          keywords: ['ikea', 'чек'],
        ),
        normalizedQuery: 'ikea',
        originalTokens: {'ikea'},
        expandedTokens: {'ikea'},
      );

      expect(
        result.evidence.any((e) => e.contains('OCR') || e.contains('IKEA')),
        isTrue,
      );
      expect(result.confidence, greaterThanOrEqualTo(95));
    });

    test('follows the explicit source priority', () {
      final photo = _photo(
        id: 'receipt',
        ocr: 'IKEA receipt 4990',
        keywords: ['ikea', 'receipt'],
      )..objects = ['Paper'];
      final ocr = ranking.rank(
        photo: photo,
        normalizedQuery: 'ikea',
        originalTokens: {'ikea'},
        expandedTokens: {'ikea'},
      );
      final keyword = ranking.rank(
        photo: _photo(id: 'keyword', keywords: ['receipt']),
        normalizedQuery: 'receipt',
        originalTokens: {'receipt'},
        expandedTokens: {'receipt'},
      );
      final category = ranking.rank(
        photo: _photo(id: 'category')..category = CategoryEngine.receipts,
        normalizedQuery: 'документ',
        originalTokens: {'документ'},
        expandedTokens: {'документ'},
        categoryFilter: CategoryEngine.receipts,
      );

      expect(ocr.score, 100);
      expect(keyword.score, lessThanOrEqualTo(95));
      expect(category.score, 80);
    });
  });
}

PhotoEntity _photo({
  required String id,
  String? ocr,
  List<String> keywords = const [],
}) {
  return PhotoEntity.create(
    mediaId: id,
    path: '/$id.jpg',
    hash: 'hash-$id',
    width: 100,
    height: 100,
    sizeBytes: 10,
    indexedAt: DateTime(2026),
    ocrText: ocr,
    keywords: keywords,
  );
}
