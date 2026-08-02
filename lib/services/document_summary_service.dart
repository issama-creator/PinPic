import 'package:pinpic/services/entity_extraction_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

/// Builds a short local "memory card" summary from OCR + category.
/// No network / LLM — delegates to [EntityExtractionService].
class DocumentSummaryService {
  DocumentSummaryService({EntityExtractionService? extractor})
    : _extractor = extractor ?? EntityExtractionService();

  final EntityExtractionService _extractor;

  ExtractedEntities extract({
    required String? ocrText,
    required String? category,
    DateTime? dateTaken,
    String? qrPayload,
  }) {
    return _extractor.extract(
      ocrText: ocrText,
      category: category,
      dateTaken: dateTaken,
      qrPayload: qrPayload,
    );
  }

  String? build({
    required String? ocrText,
    required String? category,
    DateTime? dateTaken,
    String? qrPayload,
  }) {
    return extract(
      ocrText: ocrText,
      category: category,
      dateTaken: dateTaken,
      qrPayload: qrPayload,
    ).summaryLine;
  }

  void applyToPhoto(
    PhotoEntity photo,
    ExtractedEntities entities, {
    String? fallbackTitle,
  }) {
    photo.summary = entities.summaryLine;
    photo.cardTitle = entities.cardHeadline ?? fallbackTitle;
    photo.cardBody =
        entities.cardRows.isEmpty ? null : entities.cardRows.join('\n');
    photo.entityTokens = entities.searchTokens.take(48).toList(growable: false);
  }
}
