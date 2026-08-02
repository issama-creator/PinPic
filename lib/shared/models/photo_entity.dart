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

  List<String> objects = [];

  @Index(caseSensitive: false)
  String? category;

  @Index(type: IndexType.value, caseSensitive: false)
  List<String> keywords = [];

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

  bool isFavorite = false;

  bool hasQr = false;

  String? qrPayload;

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
    this.objects = const [],
    this.category,
    this.keywords = const [],
    this.dateTaken,
    this.latitude,
    this.longitude,
    this.album,
    this.mimeType,
    this.isFavorite = false,
    this.hasQr = false,
    this.qrPayload,
    this.modifiedAt,
  });
}
