import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_summary_service.dart';
import 'package:pinpic/services/keyword_engine.dart';
import 'package:pinpic/services/local_semantic_embedding_service.dart';
import 'package:pinpic/services/ocr_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';

/// Re-runs OCR on a single indexed photo and refreshes search fields.
class PhotoTextRefreshService {
  PhotoTextRefreshService({
    required PhotoRepository photoRepository,
    OcrService? ocrService,
    CategoryEngine? categoryEngine,
    KeywordEngine? keywordEngine,
    LocalSemanticEmbeddingService? embeddingService,
    DocumentSummaryService? summaryService,
  }) : _photos = photoRepository,
       _ocr = ocrService ?? OcrService(),
       _categories = categoryEngine ?? CategoryEngine(),
       _keywords = keywordEngine ?? KeywordEngine(),
       _embeddings = embeddingService ?? LocalSemanticEmbeddingService(),
       _summaries = summaryService ?? DocumentSummaryService();

  final PhotoRepository _photos;
  final OcrService _ocr;
  final CategoryEngine _categories;
  final KeywordEngine _keywords;
  final LocalSemanticEmbeddingService _embeddings;
  final DocumentSummaryService _summaries;

  Future<PhotoEntity?> refresh(String mediaId) async {
    final photo = await _photos.findByMediaId(mediaId);
    if (photo == null) return null;

    final text = await _ocr.extractBestText(photo.path);
    final category = _categories.classify(
      ocrText: text,
      objects: const [],
      hasQr: photo.hasQr,
      displayName: photo.displayName,
      mimeType: photo.mimeType,
    );
    final entities = _summaries.extract(
      ocrText: text,
      category: category,
      dateTaken: photo.dateTaken,
      qrPayload: photo.qrPayload,
    );
    final ocrKeywords = _keywords.tokenize(text).take(120).toList();
    photo
      ..ocrText = text
      ..ocrKeywords = ocrKeywords
      ..category = category
      ..objects = const []
      ..visionKeywords = const []
      ..hasFace = false
      ..keywords = [
        ..._keywords.build(
          ocrText: text,
          objects: const [],
          category: category,
          displayName: photo.displayName,
          album: photo.album,
          qrPayload: photo.qrPayload,
          hasQr: photo.hasQr,
        ),
        ...entities.searchTokens,
      ].take(80).toList()
      ..semanticEmbedding = _embeddings.forPhoto(
        ocrTerms: ocrKeywords,
        visionTerms: const [],
        categoryTerms: [if (category != null) category],
        hasQr: photo.hasQr,
      )
      ..indexedAt = DateTime.now();
    _summaries.applyToPhoto(photo, entities, fallbackTitle: category);

    await _photos.upsert(photo);
    return photo;
  }
}
