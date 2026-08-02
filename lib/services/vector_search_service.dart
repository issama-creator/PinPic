import 'package:pinpic/services/local_semantic_embedding_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';

class SemanticCandidate {
  const SemanticCandidate({required this.photo, required this.similarity});

  final PhotoEntity photo;
  final double similarity;
}

/// Bounded local semantic retrieval. It runs after lexical candidates have
/// been collected, or as a quality-controlled fallback for natural-language
/// queries with no exact words in the index.
class VectorSearchService {
  VectorSearchService({
    required PhotoRepository photoRepository,
    LocalSemanticEmbeddingService? embeddingService,
  }) : _photos = photoRepository,
       _embeddings = embeddingService ?? LocalSemanticEmbeddingService();

  final PhotoRepository _photos;
  final LocalSemanticEmbeddingService _embeddings;

  Future<List<SemanticCandidate>> search(
    Iterable<String> queryTerms, {
    int limit = 48,
    double minSimilarity = 0.24,
  }) async {
    final queryEmbedding = _embeddings.forQuery(queryTerms);
    final pool = await _photos.semanticCandidatePool();
    final candidates = <SemanticCandidate>[];
    for (final photo in pool) {
      final similarity = _embeddings.similarity(
        queryEmbedding,
        photo.semanticEmbedding,
      );
      if (similarity >= minSimilarity) {
        candidates.add(SemanticCandidate(photo: photo, similarity: similarity));
      }
    }
    candidates.sort(
      (left, right) => right.similarity.compareTo(left.similarity),
    );
    return candidates.take(limit).toList(growable: false);
  }
}
