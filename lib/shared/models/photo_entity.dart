import 'package:isar_community/isar.dart';

part 'photo_entity.g.dart';

@Collection(accessor: 'photos')
class PhotoEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String mediaId;

  @Index()
  late String path;

  String? displayName;

  String? ocrText;

  /// Short local "memory card" line built from OCR (brand · amount · date).
  String? summary;

  /// Smart-card headline (IKEA, Договор, Wi‑Fi…).
  String? cardTitle;

  /// Smart-card body rows joined by newlines (amount, date, number…).
  String? cardBody;

  /// Searchable structured facts: amounts, phones, emails, doc numbers…
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> entityTokens = [];

  /// Normalized OCR terms are stored separately from generic keywords so the
  /// search ranker can explain an exact text match without guessing.
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> ocrKeywords = [];

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> objects = [];

  /// High-confidence labels emitted by the visual pipeline. Keeping these
  /// separate preserves their stronger weight during hybrid ranking.
  @Index(type: IndexType.value, caseSensitive: false)
  List<String> visionKeywords = [];

  @Index(caseSensitive: false)
  String? category;

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> keywords = [];

  /// Compact on-device semantic feature vector. It is derived only from local
  /// OCR, vision and metadata signals and is never uploaded.
  List<double> semanticEmbedding = [];

  @Index(unique: true, replace: true)
  late String hash;

  @Index()
  DateTime? dateTaken;

  double? latitude;

  double? longitude;

  late int width;

  late int height;

  late int sizeBytes;

  String? album;

  String? mimeType;

  @Index()
  bool isFavorite = false;

  /// Important docs (passport, license, insurance…) stay pinned on home.
  @Index()
  bool isPinned = false;

  @Index()
  bool hasQr = false;

  @Index()
  bool hasFace = false;

  /// Fast pass queued this photo for PP-OCR; survives stop/crash until deep done.
  @Index()
  bool needsDeepOcr = false;

  String? qrPayload;

  /// Expiry / valid-until date extracted from OCR when present.
  @Index()
  DateTime? expiresAt;

  late DateTime indexedAt;

  DateTime? modifiedAt;

  PhotoEntity();

  PhotoEntity.create({
    required this.mediaId,
    required this.path,
    required this.hash,
    required this.width,
    required this.height,
    required this.sizeBytes,
    required this.indexedAt,
    this.displayName,
    this.ocrText,
    this.summary,
    this.cardTitle,
    this.cardBody,
    this.entityTokens = const [],
    this.ocrKeywords = const [],
    this.objects = const [],
    this.visionKeywords = const [],
    this.category,
    this.keywords = const [],
    this.semanticEmbedding = const [],
    this.dateTaken,
    this.latitude,
    this.longitude,
    this.album,
    this.mimeType,
    this.isFavorite = false,
    this.isPinned = false,
    this.hasQr = false,
    this.hasFace = false,
    this.needsDeepOcr = false,
    this.qrPayload,
    this.expiresAt,
    this.modifiedAt,
  });
}
