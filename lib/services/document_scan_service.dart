import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pinpic/core/utils/hash_utils.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/document_summary_service.dart';
import 'package:pinpic/services/keyword_engine.dart';
import 'package:pinpic/services/local_semantic_embedding_service.dart';
import 'package:pinpic/services/ocr_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';
import 'package:pinpic/shared/repositories/settings_repository.dart';

class DocumentScanResult {
  const DocumentScanResult({
    required this.photo,
    required this.ocrText,
    required this.category,
  });

  final PhotoEntity photo;
  final String ocrText;
  final String? category;
}

/// Captures an important document photo, runs OCR immediately and upserts it
/// into the local search index without waiting for a full gallery scan.
class DocumentScanService {
  DocumentScanService({
    required PhotoRepository photoRepository,
    required SettingsRepository settingsRepository,
    OcrService? ocrService,
    CategoryEngine? categoryEngine,
    KeywordEngine? keywordEngine,
    LocalSemanticEmbeddingService? embeddingService,
    DocumentSummaryService? summaryService,
  }) : _photos = photoRepository,
       _settings = settingsRepository,
       _ocr = ocrService ?? OcrService(),
       _categories = categoryEngine ?? CategoryEngine(),
       _keywords = keywordEngine ?? KeywordEngine(),
       _embeddings = embeddingService ?? LocalSemanticEmbeddingService(),
       _summaries = summaryService ?? DocumentSummaryService();

  final PhotoRepository _photos;
  final SettingsRepository _settings;
  final OcrService _ocr;
  final CategoryEngine _categories;
  final KeywordEngine _keywords;
  final LocalSemanticEmbeddingService _embeddings;
  final DocumentSummaryService _summaries;

  Future<DocumentScanResult> ingestFile(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Файл документа не найден');
    }

    final bytes = await source.readAsBytes();
    final support = await getApplicationSupportDirectory();
    final scansDir = Directory('${support.path}/scanned_documents');
    if (!await scansDir.exists()) {
      await scansDir.create(recursive: true);
    }

    final mediaId =
        'scan_${DateTime.now().microsecondsSinceEpoch}_${bytes.length}';
    final saved = File('${scansDir.path}/$mediaId.jpg');
    await saved.writeAsBytes(bytes, flush: true);

    final ocrText = await _ocr.extractBestText(saved.path) ?? '';
    final category = _categories.classify(
      ocrText: ocrText,
      objects: const ['Document', 'Paper'],
      hasQr: false,
      displayName: 'scanned_document',
      mimeType: 'image/jpeg',
    );
    final entities = _summaries.extract(
      ocrText: ocrText,
      category: category,
      dateTaken: DateTime.now(),
    );
    final ocrKeywords = _keywords.tokenize(ocrText).take(120).toList();
    final keywords = [
      ..._keywords.build(
        ocrText: ocrText,
        objects: const ['Document', 'Paper'],
        category: category,
        displayName: 'scanned_document',
        album: 'PinPic Scans',
        hasQr: false,
      ),
      ...entities.searchTokens,
    ];
    final semantic = _embeddings.forPhoto(
      ocrTerms: ocrKeywords,
      visionTerms: const ['document', 'paper'],
      categoryTerms: [if (category != null) category],
      hasQr: false,
    );
    final hash = HashUtils.photoFingerprint(
      mediaId: mediaId,
      width: 0,
      height: 0,
      sizeBytes: bytes.length,
      modifiedAt: DateTime.now(),
    );

    final photo = PhotoEntity.create(
      mediaId: mediaId,
      path: saved.path,
      hash: hash,
      width: 0,
      height: 0,
      sizeBytes: bytes.length,
      indexedAt: DateTime.now(),
      displayName: 'Скан документа',
      ocrText: ocrText.isEmpty ? null : ocrText,
      summary: entities.summaryLine,
      ocrKeywords: ocrKeywords,
      objects: const ['Document', 'Paper'],
      visionKeywords: const ['document', 'paper'],
      category: category,
      keywords: keywords.take(80).toList(),
      semanticEmbedding: semantic,
      dateTaken: DateTime.now(),
      album: 'PinPic Scans',
      mimeType: 'image/jpeg',
      modifiedAt: DateTime.now(),
    );
    _summaries.applyToPhoto(photo, entities, fallbackTitle: category);

    await _photos.upsertAll([photo]);
    final indexed = await _photos.countAll();
    final categories = await _photos.distinctCategories();
    await _settings.updateIndexStats(
      totalPhotosFound: indexed,
      totalIndexed: indexed,
      totalCategories: categories.length,
      initialScanCompleted: true,
      indexedPipelineVersion: HashUtils.indexPipelineVersion,
    );

    return DocumentScanResult(
      photo: photo,
      ocrText: ocrText,
      category: category,
    );
  }
}
