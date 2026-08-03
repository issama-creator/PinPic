import 'package:flutter_test/flutter_test.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/fuzzy_matcher.dart';
import 'package:pinpic/services/keyword_engine.dart';
import 'package:pinpic/services/memory_query_parser.dart';
import 'package:pinpic/services/ranking_engine.dart';
import 'package:pinpic/services/synonym_engine.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

void main() {
  final parser = MemoryQueryParser();
  final synonyms = SynonymEngine();
  final fuzzy = FuzzyMatcher();
  final ranking = RankingEngine(fuzzyMatcher: fuzzy);
  final keywords = KeywordEngine(synonymEngine: synonyms);

  PhotoEntity photo({
    required String id,
    String? ocr,
    String? category,
    List<String> entityTokens = const [],
  }) {
    final built = keywords.build(
      ocrText: ocr,
      objects: const [],
      category: category,
    );
    return PhotoEntity.create(
      mediaId: id,
      path: '/$id.jpg',
      hash: id,
      width: 10,
      height: 10,
      sizeBytes: 1,
      indexedAt: DateTime(2026, 8, 3),
      ocrText: ocr,
      category: category,
      keywords: built,
      ocrKeywords: keywords.tokenize(ocr),
      entityTokens: entityTokens,
      summary: ocr,
    );
  }

  test('strips colloquial fillers from memory queries', () {
    final q = parser.parse('найди где тот чек из икеи пожалуйста');
    expect(q.meaningfulTokens, containsAll(['чек', 'икеи']));
    expect(q.meaningfulTokens.contains('найди'), isFalse);
    expect(q.meaningfulTokens.contains('где'), isFalse);
  });

  test('keeps amount digits from messy query', () {
    expect(parser.parse('примерно 4990').digitTokens, contains('4990'));
    expect(parser.parse('примерно 4 990').digitTokens, contains('4990'));
    expect(parser.parse('чек на 2.4к').digitTokens, contains('2400'));
    expect(parser.parse('чек на 5 тысяч').digitTokens, contains('5000'));
  });

  test('parses relative and seasonal date hints', () {
    final now = DateTime(2026, 8, 3); // Monday
    final yesterday = parser.parse('чек вчера', now: now);
    expect(yesterday.dateFrom, DateTime(2026, 8, 2));
    expect(yesterday.dateTo, DateTime(2026, 8, 3));

    final january = parser.parse('икея в январе', now: now);
    expect(january.dateFrom, DateTime(2026, 1, 1));
    expect(january.dateTo, DateTime(2026, 2, 1));
    expect(january.meaningfulTokens, contains('икея'));

    final winter = parser.parse('икея прошлой зимой', now: now);
    expect(winter.dateFrom, DateTime(2025, 12, 1));
    expect(winter.dateTo, DateTime(2026, 3, 1));

    // «билет» must not trigger summer via «лет».
    final ticket = parser.parse('билет', now: now);
    expect(ticket.hasDateHint, isFalse);
  });

  test('fuzzy stem finds паспорт from пасп', () {
    expect(fuzzy.isMatch('пасп', 'паспорт'), isTrue);
    expect(fuzzy.isMatch('паспрот', 'паспорт'), isTrue);
  });

  test('kolhoz passport query still ranks passport photo', () {
    final entity = photo(
      id: 'p',
      ocr: 'ПАСПОРТ RUSSIAN FEDERATION',
      category: CategoryEngine.passports,
    );
    final memory = parser.parse('найди мой паспрот');
    final tokens = memory.meaningfulTokens;
    final expanded = synonyms.expand(tokens);
    // fuzzy would add паспорт in search service; simulate here
    final fuzzyExpanded = {...expanded, 'паспорт'};
    final result = ranking.rank(
      photo: entity,
      normalizedQuery: memory.cleaned,
      originalTokens: tokens,
      expandedTokens: fuzzyExpanded,
      similarFallback: true,
    );
    expect(result.score, greaterThan(50));
    expect(result.reason.toLowerCase(), contains('паспорт'));
  });

  test('ikea amount entity is findable by digits only', () {
    final entity = photo(
      id: 'r',
      ocr: 'IKEA Total 4990 ₽',
      category: CategoryEngine.receipts,
      entityTokens: const ['4990', 'ikea'],
    );
    final memory = parser.parse('где 4990');
    final result = ranking.rank(
      photo: entity,
      normalizedQuery: memory.cleaned,
      originalTokens: memory.meaningfulTokens,
      expandedTokens: memory.meaningfulTokens,
    );
    expect(result.score, greaterThanOrEqualTo(95));
  });

  test('synonym вайфай bridges toward password intent', () {
    final expanded = synonyms.expand({'вайфай'});
    expect(expanded, contains('wifi'));
  });
}
