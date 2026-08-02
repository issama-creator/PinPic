import 'package:pinpic/services/fuzzy_matcher.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

class RankResult {
  const RankResult({
    required this.score,
    required this.confidence,
    required this.reason,
  });

  final double score;
  final int confidence;
  final String reason;
}

class RankingEngine {
  RankingEngine({FuzzyMatcher? fuzzyMatcher})
    : _fuzzy = fuzzyMatcher ?? FuzzyMatcher();

  final FuzzyMatcher _fuzzy;

  RankResult rank({
    required PhotoEntity photo,
    required String normalizedQuery,
    required Set<String> originalTokens,
    required Set<String> expandedTokens,
    bool similarFallback = false,
    String? categoryFilter,
  }) {
    final category = _normalize(photo.category ?? '');
    final ocr = _normalize(photo.ocrText ?? '');
    final name = _normalize(photo.displayName ?? '');
    final keywords = photo.keywords.map(_normalize).toSet();
    final objects = photo.objects.map(_normalize).toSet();

    var score = 0.0;
    String? reason;

    // A candidate that only surfaced because it was filtered by exact
    // `category` (e.g. quick category tiles with no free-text query) is
    // already a guaranteed match — give it a confident, descriptive reason
    // instead of falling through to the generic "similar" copy.
    if (categoryFilter != null &&
        category == _normalize(categoryFilter) &&
        category.isNotEmpty) {
      score += 90;
      reason = 'Найдено в категории «${photo.category}»';
    }

    if (normalizedQuery.isNotEmpty && category == normalizedQuery) {
      score += 100;
      reason = 'Найдено в категории «${photo.category}»';
    } else if (normalizedQuery.isNotEmpty &&
        category.contains(normalizedQuery)) {
      score += 80;
      reason = 'Найдено в категории «${photo.category}»';
    }

    if (photo.hasQr && expandedTokens.any((token) => token.startsWith('qr'))) {
      score += 100;
      reason ??= 'Найден QR-код';
    }

    if (normalizedQuery.length >= 3 && ocr.contains(normalizedQuery)) {
      score += 95;
      reason ??= 'Найдено по OCR: «$normalizedQuery»';
    }

    for (final token in expandedTokens) {
      if (keywords.contains(token)) {
        score += originalTokens.contains(token) ? 72 : 52;
        reason ??= originalTokens.contains(token)
            ? 'Найдено по слову «$token»'
            : 'Найдено по смыслу запроса';
        continue;
      }

      if (keywords.any((keyword) => keyword.startsWith(token))) {
        score += 42;
        reason ??= 'Найдено по началу слова «$token»';
      } else if (objects.any(
        (object) => object == token || object.contains(token),
      )) {
        score += 60;
        reason ??= 'Найдено по объекту «$token»';
      } else if (ocr.contains(token)) {
        score += 65;
        reason ??= 'Найдено по OCR: «$token»';
      } else if (name.contains(token)) {
        score += 28;
        reason ??= 'Найдено по имени файла';
      } else {
        final fuzzyKeyword = keywords.cast<String?>().firstWhere(
          (keyword) => _fuzzy.isMatch(token, keyword!),
          orElse: () => null,
        );
        if (fuzzyKeyword != null) {
          score += 30 * _fuzzy.similarity(token, fuzzyKeyword);
          reason ??= 'Похоже на «$fuzzyKeyword»';
        }
      }
    }

    if (photo.isFavorite) score += 3;
    final taken = photo.dateTaken;
    if (taken != null) {
      final age = DateTime.now().difference(taken).inDays;
      if (age <= 30) {
        score += 3;
      } else if (age <= 365) {
        score += 1;
      }
    }

    final matchedOriginal = originalTokens.where((token) {
      return keywords.contains(token) ||
          ocr.contains(token) ||
          objects.any((object) => object.contains(token));
    }).length;
    if (originalTokens.length > 1 && matchedOriginal == originalTokens.length) {
      score += 24;
    }

    final confidence = _confidence(score, similarFallback);
    return RankResult(
      score: score,
      confidence: confidence,
      reason:
          reason ??
          (similarFallback ? 'Похожий результат' : 'Совпадение по запросу'),
    );
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll('ё', 'е');

  int _confidence(double score, bool similarFallback) {
    if (similarFallback) {
      // Honest band: weak fuzzy hits stay visibly weaker than real matches.
      return score.round().clamp(20, 69);
    }
    return score.round().clamp(40, 99);
  }
}
