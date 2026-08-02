import 'package:pinpic/services/fuzzy_matcher.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

class RankResult {
  const RankResult({
    required this.score,
    required this.confidence,
    required this.reason,
    required this.evidence,
    required this.isSimilar,
  });

  final double score;
  final int confidence;
  final String reason;
  final List<String> evidence;
  final bool isSimilar;
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
    double semanticSimilarity = 0,
  }) {
    final category = _normalize(photo.category ?? '');
    final ocr = _normalize(photo.ocrText ?? '');
    final name = _normalize(photo.displayName ?? '');
    final summary = _normalize(photo.summary ?? '');
    final cardBody = _normalize(photo.cardBody ?? '');
    final keywords = photo.keywords.map(_normalize).toSet();
    final objects = photo.objects.map(_normalize).toSet();
    final ocrKeywords = photo.ocrKeywords.map(_normalize).toSet();
    final entityTokens = photo.entityTokens.map(_normalize).toSet();
    final pool = {
      ...keywords,
      ...ocrKeywords,
      ...entityTokens,
      ...objects,
    };

    var score = 0.0;
    final evidence = <String>[];
    var matchedOriginalCount = 0;

    void addEvidence(String value) {
      if (!evidence.contains(value)) evidence.add(value);
    }

    void scoreAtLeast(double value, String why) {
      if (value > score) score = value;
      addEvidence(why);
    }

    if (categoryFilter != null &&
        category == _normalize(categoryFilter) &&
        category.isNotEmpty) {
      scoreAtLeast(80, '✓ ${photo.category}');
    }

    if (normalizedQuery.isNotEmpty && category == normalizedQuery) {
      scoreAtLeast(80, '✓ ${photo.category}');
    } else if (normalizedQuery.isNotEmpty &&
        category.contains(normalizedQuery)) {
      scoreAtLeast(80, '✓ ${photo.category}');
    }

    if (photo.hasQr && expandedTokens.any((token) => token.startsWith('qr'))) {
      scoreAtLeast(98, '✓ QR');
    }

    if (normalizedQuery.length >= 3 &&
        (ocr.contains(normalizedQuery) ||
            summary.contains(normalizedQuery) ||
            cardBody.contains(normalizedQuery))) {
      scoreAtLeast(100, '✓ OCR');
      addEvidence('✓ ${_prettyToken(normalizedQuery)}');
    }

    for (final token in expandedTokens) {
      var tokenHit = false;

      if (entityTokens.contains(token) ||
          entityTokens.any((entity) => entity.contains(token))) {
        scoreAtLeast(100, '✓ ${_prettyToken(token)}');
        tokenHit = true;
      } else if (objects.any(
        (object) => object == token || object.contains(token),
      )) {
        scoreAtLeast(90, '✓ ${_prettyToken(token)}');
        tokenHit = true;
      } else if (keywords.contains(token)) {
        final fromOcr = ocr.contains(token) || ocrKeywords.contains(token);
        scoreAtLeast(
          originalTokens.contains(token) ? 95 : 72,
          originalTokens.contains(token)
              ? (fromOcr ? '✓ OCR' : '✓ ${_prettyToken(token)}')
              : '✓ ${_prettyToken(token)}',
        );
        if (fromOcr && originalTokens.contains(token)) {
          addEvidence('✓ ${_prettyToken(token)}');
        }
        tokenHit = true;
      } else if (keywords.any((keyword) => keyword.startsWith(token)) ||
          ocrKeywords.any((keyword) => keyword.startsWith(token))) {
        scoreAtLeast(78, '✓ ${_prettyToken(token)}');
        tokenHit = true;
      } else if (ocr.contains(token) ||
          summary.contains(token) ||
          cardBody.contains(token)) {
        scoreAtLeast(100, '✓ OCR');
        addEvidence('✓ ${_prettyToken(token)}');
        tokenHit = true;
      } else if (name.contains(token)) {
        scoreAtLeast(45, '✓ ${_prettyToken(token)}');
        tokenHit = true;
      } else {
        final fuzzyHit = pool.cast<String?>().firstWhere(
          (candidate) => _fuzzy.isMatch(token, candidate!),
          orElse: () => null,
        );
        if (fuzzyHit != null) {
          final sim = _fuzzy.similarity(token, fuzzyHit);
          scoreAtLeast(
            (55 + sim * 30).clamp(40, 88),
            '✓ ${_prettyToken(fuzzyHit)}',
          );
          tokenHit = true;
        }
      }

      if (tokenHit && originalTokens.contains(token)) {
        matchedOriginalCount++;
      } else if (tokenHit) {
        // Synonym / fuzzy expansion still counts toward partial memory match.
        matchedOriginalCount += 0;
      }
    }

    // Count original tokens matched via fuzzy/synonym against the photo.
    matchedOriginalCount = originalTokens.where((token) {
      if (keywords.contains(token) ||
          entityTokens.contains(token) ||
          ocr.contains(token) ||
          summary.contains(token) ||
          objects.any((object) => object.contains(token))) {
        return true;
      }
      return pool.any((candidate) => _fuzzy.isMatch(token, candidate));
    }).length;

    if (photo.category != null &&
        originalTokens.any(
          (token) =>
              _normalize(photo.category!).contains(token) ||
              token.contains(_normalize(photo.category!)) ||
              _fuzzy.isMatch(token, photo.category!),
        )) {
      addEvidence('✓ ${photo.category}');
      if (score < 80) scoreAtLeast(80, '✓ ${photo.category}');
    }

    if (semanticSimilarity > 0) {
      final semanticScore = 50 + semanticSimilarity * 19;
      scoreAtLeast(semanticScore.clamp(50, 69), '✓ По смыслу');
    }

    if (originalTokens.length > 1) {
      final coverage = matchedOriginalCount / originalTokens.length;
      if (coverage >= 1) {
        score = (score + 8).clamp(0, 100);
      } else if (coverage >= 0.5 && score > 0) {
        // «чек икеа» with only IKEA still stays useful, not discarded.
        score = (score + 3).clamp(0, 100);
      }
    }

    final isSimilar =
        similarFallback ||
        (semanticSimilarity > 0 && score < 80) ||
        (score > 0 && score < 55 && matchedOriginalCount == 0);
    final confidence = _confidence(score, isSimilar);
    return RankResult(
      score: score,
      confidence: confidence,
      evidence: evidence,
      isSimilar: isSimilar,
      reason: evidence.isEmpty
          ? (isSimilar ? 'Похожий результат' : 'Совпадение по запросу')
          : evidence.first,
    );
  }

  String _normalize(String value) =>
      value.trim().toLowerCase().replaceAll('ё', 'е');

  String _prettyToken(String token) {
    if (token.isEmpty) return token;
    if (token == token.toUpperCase() && token.length <= 6) return token;
    if (RegExp(r'^[a-z0-9]+$').hasMatch(token) && token.length <= 8) {
      return token.toUpperCase();
    }
    return token;
  }

  int _confidence(double score, bool isSimilar) {
    if (isSimilar) {
      return score.round().clamp(20, 69);
    }
    return score.round().clamp(40, 99);
  }
}
