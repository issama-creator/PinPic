import 'dart:math' as math;

import 'package:pinpic/services/synonym_engine.dart';

/// Small, deterministic on-device embedding used to merge text, OCR and
/// visual labels into one semantic signal.
///
/// It deliberately has no network or server dependency. The feature hashing
/// scheme makes synonym-related queries share dimensions with the locally
/// indexed OCR/vision tokens. A future dual-encoder TFLite model can replace
/// this implementation without changing storage or search APIs.
class LocalSemanticEmbeddingService {
  LocalSemanticEmbeddingService({SynonymEngine? synonyms})
    : _synonyms = synonyms ?? SynonymEngine();

  static const dimensions = 96;

  final SynonymEngine _synonyms;

  List<double> forPhoto({
    required Iterable<String> ocrTerms,
    required Iterable<String> visionTerms,
    required Iterable<String> categoryTerms,
    required bool hasQr,
  }) {
    return _embed(<String, double>{
      for (final term in ocrTerms) term: 1.0,
      for (final term in visionTerms) term: 1.35,
      for (final term in categoryTerms) term: 1.2,
      if (hasQr) 'qr': 1.25,
    });
  }

  List<double> forQuery(Iterable<String> queryTerms) {
    final terms = _synonyms.expand(queryTerms);
    return _embed({for (final term in terms) term: 1.0});
  }

  double similarity(List<double> left, List<double> right) {
    if (left.length != dimensions || right.length != dimensions) return 0;
    var dot = 0.0;
    for (var index = 0; index < dimensions; index++) {
      dot += left[index] * right[index];
    }
    // Vectors are normalized by [_embed], so cosine similarity is their dot
    // product. Hash collisions can make it slightly negative.
    return dot.clamp(0.0, 1.0);
  }

  List<double> _embed(Map<String, double> weightedTerms) {
    final vector = List<double>.filled(dimensions, 0);
    for (final entry in weightedTerms.entries) {
      final normalized = _synonyms.normalize(entry.key);
      if (normalized.isEmpty) continue;
      final expanded = _synonyms.expand({normalized});
      for (final term in expanded) {
        final hash = _stableHash(term);
        final index = hash.abs() % dimensions;
        final direction = hash.isEven ? 1.0 : -1.0;
        vector[index] += direction * entry.value;
      }
    }

    final length = math.sqrt(
      vector.fold<double>(0, (sum, value) => sum + value * value),
    );
    if (length == 0) return vector;
    return vector.map((value) => value / length).toList(growable: false);
  }

  int _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash;
  }
}
