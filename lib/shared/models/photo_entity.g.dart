// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPhotoEntityCollection on Isar {
  IsarCollection<PhotoEntity> get photos => this.collection();
}

const PhotoEntitySchema = CollectionSchema(
  name: r'PhotoEntity',
  id: 8245672414119462092,
  properties: {
    r'album': PropertySchema(id: 0, name: r'album', type: IsarType.string),
    r'cardBody': PropertySchema(
      id: 1,
      name: r'cardBody',
      type: IsarType.string,
    ),
    r'cardTitle': PropertySchema(
      id: 2,
      name: r'cardTitle',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 3,
      name: r'category',
      type: IsarType.string,
    ),
    r'dateTaken': PropertySchema(
      id: 4,
      name: r'dateTaken',
      type: IsarType.dateTime,
    ),
    r'displayName': PropertySchema(
      id: 5,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'entityTokens': PropertySchema(
      id: 6,
      name: r'entityTokens',
      type: IsarType.stringList,
    ),
    r'expiresAt': PropertySchema(
      id: 7,
      name: r'expiresAt',
      type: IsarType.dateTime,
    ),
    r'hasFace': PropertySchema(id: 8, name: r'hasFace', type: IsarType.bool),
    r'hasQr': PropertySchema(id: 9, name: r'hasQr', type: IsarType.bool),
    r'hash': PropertySchema(id: 10, name: r'hash', type: IsarType.string),
    r'height': PropertySchema(id: 11, name: r'height', type: IsarType.long),
    r'indexedAt': PropertySchema(
      id: 12,
      name: r'indexedAt',
      type: IsarType.dateTime,
    ),
    r'isFavorite': PropertySchema(
      id: 13,
      name: r'isFavorite',
      type: IsarType.bool,
    ),
    r'isPinned': PropertySchema(id: 14, name: r'isPinned', type: IsarType.bool),
    r'keywords': PropertySchema(
      id: 15,
      name: r'keywords',
      type: IsarType.stringList,
    ),
    r'latitude': PropertySchema(
      id: 16,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 17,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'mediaId': PropertySchema(id: 18, name: r'mediaId', type: IsarType.string),
    r'mimeType': PropertySchema(
      id: 19,
      name: r'mimeType',
      type: IsarType.string,
    ),
    r'modifiedAt': PropertySchema(
      id: 20,
      name: r'modifiedAt',
      type: IsarType.dateTime,
    ),
    r'needsDeepOcr': PropertySchema(
      id: 21,
      name: r'needsDeepOcr',
      type: IsarType.bool,
    ),
    r'objects': PropertySchema(
      id: 22,
      name: r'objects',
      type: IsarType.stringList,
    ),
    r'ocrKeywords': PropertySchema(
      id: 23,
      name: r'ocrKeywords',
      type: IsarType.stringList,
    ),
    r'ocrText': PropertySchema(id: 24, name: r'ocrText', type: IsarType.string),
    r'path': PropertySchema(id: 25, name: r'path', type: IsarType.string),
    r'qrPayload': PropertySchema(
      id: 26,
      name: r'qrPayload',
      type: IsarType.string,
    ),
    r'semanticEmbedding': PropertySchema(
      id: 27,
      name: r'semanticEmbedding',
      type: IsarType.doubleList,
    ),
    r'sizeBytes': PropertySchema(
      id: 28,
      name: r'sizeBytes',
      type: IsarType.long,
    ),
    r'summary': PropertySchema(id: 29, name: r'summary', type: IsarType.string),
    r'visionKeywords': PropertySchema(
      id: 30,
      name: r'visionKeywords',
      type: IsarType.stringList,
    ),
    r'width': PropertySchema(id: 31, name: r'width', type: IsarType.long),
  },

  estimateSize: _photoEntityEstimateSize,
  serialize: _photoEntitySerialize,
  deserialize: _photoEntityDeserialize,
  deserializeProp: _photoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'mediaId': IndexSchema(
      id: -8001372983137409759,
      name: r'mediaId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'mediaId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'path': IndexSchema(
      id: 8756705481922369689,
      name: r'path',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'path',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'entityTokens': IndexSchema(
      id: -5318890006452615364,
      name: r'entityTokens',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entityTokens',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'ocrKeywords': IndexSchema(
      id: 2405297807147412282,
      name: r'ocrKeywords',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ocrKeywords',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'objects': IndexSchema(
      id: -3299248853131431977,
      name: r'objects',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'objects',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'visionKeywords': IndexSchema(
      id: -2160034419788734854,
      name: r'visionKeywords',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'visionKeywords',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'category': IndexSchema(
      id: -7560358558326323820,
      name: r'category',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'category',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
    r'keywords': IndexSchema(
      id: -5743176046722291771,
      name: r'keywords',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'keywords',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'hash': IndexSchema(
      id: -7973251393006690288,
      name: r'hash',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'hash',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
    r'dateTaken': IndexSchema(
      id: 9200557840532179902,
      name: r'dateTaken',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dateTaken',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'isFavorite': IndexSchema(
      id: 5742774614603939776,
      name: r'isFavorite',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isFavorite',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'isPinned': IndexSchema(
      id: 7607338673446676027,
      name: r'isPinned',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isPinned',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'hasQr': IndexSchema(
      id: 2520744088735484928,
      name: r'hasQr',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hasQr',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'hasFace': IndexSchema(
      id: -4320032872621253416,
      name: r'hasFace',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'hasFace',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'needsDeepOcr': IndexSchema(
      id: -1610758615210310035,
      name: r'needsDeepOcr',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'needsDeepOcr',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
    r'expiresAt': IndexSchema(
      id: 4994901953235663716,
      name: r'expiresAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'expiresAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _photoEntityGetId,
  getLinks: _photoEntityGetLinks,
  attach: _photoEntityAttach,
  version: '3.3.2',
);

int _photoEntityEstimateSize(
  PhotoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.album;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cardBody;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.cardTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.category;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.displayName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.entityTokens.length * 3;
  {
    for (var i = 0; i < object.entityTokens.length; i++) {
      final value = object.entityTokens[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.hash.length * 3;
  bytesCount += 3 + object.keywords.length * 3;
  {
    for (var i = 0; i < object.keywords.length; i++) {
      final value = object.keywords[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mediaId.length * 3;
  {
    final value = object.mimeType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.objects.length * 3;
  {
    for (var i = 0; i < object.objects.length; i++) {
      final value = object.objects[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.ocrKeywords.length * 3;
  {
    for (var i = 0; i < object.ocrKeywords.length; i++) {
      final value = object.ocrKeywords[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.ocrText;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.path.length * 3;
  {
    final value = object.qrPayload;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.semanticEmbedding.length * 8;
  {
    final value = object.summary;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.visionKeywords.length * 3;
  {
    for (var i = 0; i < object.visionKeywords.length; i++) {
      final value = object.visionKeywords[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _photoEntitySerialize(
  PhotoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.album);
  writer.writeString(offsets[1], object.cardBody);
  writer.writeString(offsets[2], object.cardTitle);
  writer.writeString(offsets[3], object.category);
  writer.writeDateTime(offsets[4], object.dateTaken);
  writer.writeString(offsets[5], object.displayName);
  writer.writeStringList(offsets[6], object.entityTokens);
  writer.writeDateTime(offsets[7], object.expiresAt);
  writer.writeBool(offsets[8], object.hasFace);
  writer.writeBool(offsets[9], object.hasQr);
  writer.writeString(offsets[10], object.hash);
  writer.writeLong(offsets[11], object.height);
  writer.writeDateTime(offsets[12], object.indexedAt);
  writer.writeBool(offsets[13], object.isFavorite);
  writer.writeBool(offsets[14], object.isPinned);
  writer.writeStringList(offsets[15], object.keywords);
  writer.writeDouble(offsets[16], object.latitude);
  writer.writeDouble(offsets[17], object.longitude);
  writer.writeString(offsets[18], object.mediaId);
  writer.writeString(offsets[19], object.mimeType);
  writer.writeDateTime(offsets[20], object.modifiedAt);
  writer.writeBool(offsets[21], object.needsDeepOcr);
  writer.writeStringList(offsets[22], object.objects);
  writer.writeStringList(offsets[23], object.ocrKeywords);
  writer.writeString(offsets[24], object.ocrText);
  writer.writeString(offsets[25], object.path);
  writer.writeString(offsets[26], object.qrPayload);
  writer.writeDoubleList(offsets[27], object.semanticEmbedding);
  writer.writeLong(offsets[28], object.sizeBytes);
  writer.writeString(offsets[29], object.summary);
  writer.writeStringList(offsets[30], object.visionKeywords);
  writer.writeLong(offsets[31], object.width);
}

PhotoEntity _photoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PhotoEntity();
  object.album = reader.readStringOrNull(offsets[0]);
  object.cardBody = reader.readStringOrNull(offsets[1]);
  object.cardTitle = reader.readStringOrNull(offsets[2]);
  object.category = reader.readStringOrNull(offsets[3]);
  object.dateTaken = reader.readDateTimeOrNull(offsets[4]);
  object.displayName = reader.readStringOrNull(offsets[5]);
  object.entityTokens = reader.readStringList(offsets[6]) ?? [];
  object.expiresAt = reader.readDateTimeOrNull(offsets[7]);
  object.hasFace = reader.readBool(offsets[8]);
  object.hasQr = reader.readBool(offsets[9]);
  object.hash = reader.readString(offsets[10]);
  object.height = reader.readLong(offsets[11]);
  object.id = id;
  object.indexedAt = reader.readDateTime(offsets[12]);
  object.isFavorite = reader.readBool(offsets[13]);
  object.isPinned = reader.readBool(offsets[14]);
  object.keywords = reader.readStringList(offsets[15]) ?? [];
  object.latitude = reader.readDoubleOrNull(offsets[16]);
  object.longitude = reader.readDoubleOrNull(offsets[17]);
  object.mediaId = reader.readString(offsets[18]);
  object.mimeType = reader.readStringOrNull(offsets[19]);
  object.modifiedAt = reader.readDateTimeOrNull(offsets[20]);
  object.needsDeepOcr = reader.readBool(offsets[21]);
  object.objects = reader.readStringList(offsets[22]) ?? [];
  object.ocrKeywords = reader.readStringList(offsets[23]) ?? [];
  object.ocrText = reader.readStringOrNull(offsets[24]);
  object.path = reader.readString(offsets[25]);
  object.qrPayload = reader.readStringOrNull(offsets[26]);
  object.semanticEmbedding = reader.readDoubleList(offsets[27]) ?? [];
  object.sizeBytes = reader.readLong(offsets[28]);
  object.summary = reader.readStringOrNull(offsets[29]);
  object.visionKeywords = reader.readStringList(offsets[30]) ?? [];
  object.width = reader.readLong(offsets[31]);
  return object;
}

P _photoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringList(offset) ?? []) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readStringList(offset) ?? []) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readDoubleOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 21:
      return (reader.readBool(offset)) as P;
    case 22:
      return (reader.readStringList(offset) ?? []) as P;
    case 23:
      return (reader.readStringList(offset) ?? []) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 28:
      return (reader.readLong(offset)) as P;
    case 29:
      return (reader.readStringOrNull(offset)) as P;
    case 30:
      return (reader.readStringList(offset) ?? []) as P;
    case 31:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _photoEntityGetId(PhotoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _photoEntityGetLinks(PhotoEntity object) {
  return [];
}

void _photoEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  PhotoEntity object,
) {
  object.id = id;
}

extension PhotoEntityByIndex on IsarCollection<PhotoEntity> {
  Future<PhotoEntity?> getByMediaId(String mediaId) {
    return getByIndex(r'mediaId', [mediaId]);
  }

  PhotoEntity? getByMediaIdSync(String mediaId) {
    return getByIndexSync(r'mediaId', [mediaId]);
  }

  Future<bool> deleteByMediaId(String mediaId) {
    return deleteByIndex(r'mediaId', [mediaId]);
  }

  bool deleteByMediaIdSync(String mediaId) {
    return deleteByIndexSync(r'mediaId', [mediaId]);
  }

  Future<List<PhotoEntity?>> getAllByMediaId(List<String> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'mediaId', values);
  }

  List<PhotoEntity?> getAllByMediaIdSync(List<String> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'mediaId', values);
  }

  Future<int> deleteAllByMediaId(List<String> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'mediaId', values);
  }

  int deleteAllByMediaIdSync(List<String> mediaIdValues) {
    final values = mediaIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'mediaId', values);
  }

  Future<Id> putByMediaId(PhotoEntity object) {
    return putByIndex(r'mediaId', object);
  }

  Id putByMediaIdSync(PhotoEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'mediaId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByMediaId(List<PhotoEntity> objects) {
    return putAllByIndex(r'mediaId', objects);
  }

  List<Id> putAllByMediaIdSync(
    List<PhotoEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'mediaId', objects, saveLinks: saveLinks);
  }

  Future<PhotoEntity?> getByHash(String hash) {
    return getByIndex(r'hash', [hash]);
  }

  PhotoEntity? getByHashSync(String hash) {
    return getByIndexSync(r'hash', [hash]);
  }

  Future<bool> deleteByHash(String hash) {
    return deleteByIndex(r'hash', [hash]);
  }

  bool deleteByHashSync(String hash) {
    return deleteByIndexSync(r'hash', [hash]);
  }

  Future<List<PhotoEntity?>> getAllByHash(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return getAllByIndex(r'hash', values);
  }

  List<PhotoEntity?> getAllByHashSync(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'hash', values);
  }

  Future<int> deleteAllByHash(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'hash', values);
  }

  int deleteAllByHashSync(List<String> hashValues) {
    final values = hashValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'hash', values);
  }

  Future<Id> putByHash(PhotoEntity object) {
    return putByIndex(r'hash', object);
  }

  Id putByHashSync(PhotoEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'hash', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByHash(List<PhotoEntity> objects) {
    return putAllByIndex(r'hash', objects);
  }

  List<Id> putAllByHashSync(
    List<PhotoEntity> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'hash', objects, saveLinks: saveLinks);
  }
}

extension PhotoEntityQueryWhereSort
    on QueryBuilder<PhotoEntity, PhotoEntity, QWhere> {
  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyEntityTokensElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'entityTokens'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyOcrKeywordsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ocrKeywords'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyObjectsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'objects'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere>
  anyVisionKeywordsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'visionKeywords'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyKeywordsElement() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'keywords'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'dateTaken'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isFavorite'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isPinned'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyHasQr() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hasQr'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyHasFace() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'hasFace'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyNeedsDeepOcr() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'needsDeepOcr'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhere> anyExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'expiresAt'),
      );
    });
  }
}

extension PhotoEntityQueryWhere
    on QueryBuilder<PhotoEntity, PhotoEntity, QWhereClause> {
  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> mediaIdEqualTo(
    String mediaId,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'mediaId', value: [mediaId]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> mediaIdNotEqualTo(
    String mediaId,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [],
                upper: [mediaId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [mediaId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [mediaId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'mediaId',
                lower: [],
                upper: [mediaId],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> pathEqualTo(
    String path,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'path', value: [path]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> pathNotEqualTo(
    String path,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [],
                upper: [path],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [path],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [path],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'path',
                lower: [],
                upper: [path],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementEqualTo(String entityTokensElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'entityTokens',
          value: [entityTokensElement],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementNotEqualTo(String entityTokensElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityTokens',
                lower: [],
                upper: [entityTokensElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityTokens',
                lower: [entityTokensElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityTokens',
                lower: [entityTokensElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'entityTokens',
                lower: [],
                upper: [entityTokensElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementGreaterThan(
    String entityTokensElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entityTokens',
          lower: [entityTokensElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementLessThan(
    String entityTokensElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entityTokens',
          lower: [],
          upper: [entityTokensElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementBetween(
    String lowerEntityTokensElement,
    String upperEntityTokensElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entityTokens',
          lower: [lowerEntityTokensElement],
          includeLower: includeLower,
          upper: [upperEntityTokensElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementStartsWith(String EntityTokensElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'entityTokens',
          lower: [EntityTokensElementPrefix],
          upper: ['$EntityTokensElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'entityTokens', value: ['']),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  entityTokensElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'entityTokens',
                upper: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'entityTokens',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'entityTokens',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'entityTokens',
                upper: [''],
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementEqualTo(String ocrKeywordsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'ocrKeywords',
          value: [ocrKeywordsElement],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementNotEqualTo(String ocrKeywordsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ocrKeywords',
                lower: [],
                upper: [ocrKeywordsElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ocrKeywords',
                lower: [ocrKeywordsElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ocrKeywords',
                lower: [ocrKeywordsElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'ocrKeywords',
                lower: [],
                upper: [ocrKeywordsElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementGreaterThan(
    String ocrKeywordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ocrKeywords',
          lower: [ocrKeywordsElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementLessThan(
    String ocrKeywordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ocrKeywords',
          lower: [],
          upper: [ocrKeywordsElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementBetween(
    String lowerOcrKeywordsElement,
    String upperOcrKeywordsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ocrKeywords',
          lower: [lowerOcrKeywordsElement],
          includeLower: includeLower,
          upper: [upperOcrKeywordsElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementStartsWith(String OcrKeywordsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'ocrKeywords',
          lower: [OcrKeywordsElementPrefix],
          upper: ['$OcrKeywordsElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'ocrKeywords', value: ['']),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  ocrKeywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'ocrKeywords', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'ocrKeywords',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'ocrKeywords',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'ocrKeywords', upper: ['']),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementEqualTo(String objectsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'objects',
          value: [objectsElement],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementNotEqualTo(String objectsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'objects',
                lower: [],
                upper: [objectsElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'objects',
                lower: [objectsElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'objects',
                lower: [objectsElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'objects',
                lower: [],
                upper: [objectsElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementGreaterThan(String objectsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'objects',
          lower: [objectsElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementLessThan(String objectsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'objects',
          lower: [],
          upper: [objectsElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementBetween(
    String lowerObjectsElement,
    String upperObjectsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'objects',
          lower: [lowerObjectsElement],
          includeLower: includeLower,
          upper: [upperObjectsElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementStartsWith(String ObjectsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'objects',
          lower: [ObjectsElementPrefix],
          upper: ['$ObjectsElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'objects', value: ['']),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  objectsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'objects', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'objects', lower: ['']),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'objects', lower: ['']),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'objects', upper: ['']),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementEqualTo(String visionKeywordsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'visionKeywords',
          value: [visionKeywordsElement],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementNotEqualTo(String visionKeywordsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'visionKeywords',
                lower: [],
                upper: [visionKeywordsElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'visionKeywords',
                lower: [visionKeywordsElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'visionKeywords',
                lower: [visionKeywordsElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'visionKeywords',
                lower: [],
                upper: [visionKeywordsElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementGreaterThan(
    String visionKeywordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'visionKeywords',
          lower: [visionKeywordsElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementLessThan(
    String visionKeywordsElement, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'visionKeywords',
          lower: [],
          upper: [visionKeywordsElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementBetween(
    String lowerVisionKeywordsElement,
    String upperVisionKeywordsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'visionKeywords',
          lower: [lowerVisionKeywordsElement],
          includeLower: includeLower,
          upper: [upperVisionKeywordsElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementStartsWith(String VisionKeywordsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'visionKeywords',
          lower: [VisionKeywordsElementPrefix],
          upper: ['$VisionKeywordsElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'visionKeywords', value: ['']),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  visionKeywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'visionKeywords',
                upper: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'visionKeywords',
                lower: [''],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(
                indexName: r'visionKeywords',
                lower: [''],
              ),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(
                indexName: r'visionKeywords',
                upper: [''],
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'category', value: [null]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'category',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> categoryEqualTo(
    String? category,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'category', value: [category]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> categoryNotEqualTo(
    String? category,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'category',
                lower: [],
                upper: [category],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'category',
                lower: [category],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'category',
                lower: [category],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'category',
                lower: [],
                upper: [category],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementEqualTo(String keywordsElement) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'keywords',
          value: [keywordsElement],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementNotEqualTo(String keywordsElement) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'keywords',
                lower: [],
                upper: [keywordsElement],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'keywords',
                lower: [keywordsElement],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'keywords',
                lower: [keywordsElement],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'keywords',
                lower: [],
                upper: [keywordsElement],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementGreaterThan(String keywordsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'keywords',
          lower: [keywordsElement],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementLessThan(String keywordsElement, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'keywords',
          lower: [],
          upper: [keywordsElement],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementBetween(
    String lowerKeywordsElement,
    String upperKeywordsElement, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'keywords',
          lower: [lowerKeywordsElement],
          includeLower: includeLower,
          upper: [upperKeywordsElement],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementStartsWith(String KeywordsElementPrefix) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'keywords',
          lower: [KeywordsElementPrefix],
          upper: ['$KeywordsElementPrefix\u{FFFFF}'],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'keywords', value: ['']),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  keywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'keywords', upper: ['']),
            )
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'keywords', lower: ['']),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.greaterThan(indexName: r'keywords', lower: ['']),
            )
            .addWhereClause(
              IndexWhereClause.lessThan(indexName: r'keywords', upper: ['']),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> hashEqualTo(
    String hash,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'hash', value: [hash]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> hashNotEqualTo(
    String hash,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hash',
                lower: [],
                upper: [hash],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hash',
                lower: [hash],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hash',
                lower: [hash],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hash',
                lower: [],
                upper: [hash],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> dateTakenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dateTaken', value: [null]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  dateTakenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dateTaken',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> dateTakenEqualTo(
    DateTime? dateTaken,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'dateTaken', value: [dateTaken]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> dateTakenNotEqualTo(
    DateTime? dateTaken,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateTaken',
                lower: [],
                upper: [dateTaken],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateTaken',
                lower: [dateTaken],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateTaken',
                lower: [dateTaken],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'dateTaken',
                lower: [],
                upper: [dateTaken],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  dateTakenGreaterThan(DateTime? dateTaken, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dateTaken',
          lower: [dateTaken],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> dateTakenLessThan(
    DateTime? dateTaken, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dateTaken',
          lower: [],
          upper: [dateTaken],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> dateTakenBetween(
    DateTime? lowerDateTaken,
    DateTime? upperDateTaken, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'dateTaken',
          lower: [lowerDateTaken],
          includeLower: includeLower,
          upper: [upperDateTaken],
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> isFavoriteEqualTo(
    bool isFavorite,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isFavorite', value: [isFavorite]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  isFavoriteNotEqualTo(bool isFavorite) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [],
                upper: [isFavorite],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [isFavorite],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [isFavorite],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isFavorite',
                lower: [],
                upper: [isFavorite],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> isPinnedEqualTo(
    bool isPinned,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'isPinned', value: [isPinned]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> isPinnedNotEqualTo(
    bool isPinned,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPinned',
                lower: [],
                upper: [isPinned],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPinned',
                lower: [isPinned],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPinned',
                lower: [isPinned],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'isPinned',
                lower: [],
                upper: [isPinned],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> hasQrEqualTo(
    bool hasQr,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'hasQr', value: [hasQr]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> hasQrNotEqualTo(
    bool hasQr,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasQr',
                lower: [],
                upper: [hasQr],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasQr',
                lower: [hasQr],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasQr',
                lower: [hasQr],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasQr',
                lower: [],
                upper: [hasQr],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> hasFaceEqualTo(
    bool hasFace,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'hasFace', value: [hasFace]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> hasFaceNotEqualTo(
    bool hasFace,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasFace',
                lower: [],
                upper: [hasFace],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasFace',
                lower: [hasFace],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasFace',
                lower: [hasFace],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'hasFace',
                lower: [],
                upper: [hasFace],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> needsDeepOcrEqualTo(
    bool needsDeepOcr,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'needsDeepOcr',
          value: [needsDeepOcr],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  needsDeepOcrNotEqualTo(bool needsDeepOcr) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'needsDeepOcr',
                lower: [],
                upper: [needsDeepOcr],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'needsDeepOcr',
                lower: [needsDeepOcr],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'needsDeepOcr',
                lower: [needsDeepOcr],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'needsDeepOcr',
                lower: [],
                upper: [needsDeepOcr],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'expiresAt', value: [null]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [null],
          includeLower: false,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> expiresAtEqualTo(
    DateTime? expiresAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'expiresAt', value: [expiresAt]),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> expiresAtNotEqualTo(
    DateTime? expiresAt,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [],
                upper: [expiresAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [expiresAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [expiresAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'expiresAt',
                lower: [],
                upper: [expiresAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause>
  expiresAtGreaterThan(DateTime? expiresAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [expiresAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> expiresAtLessThan(
    DateTime? expiresAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [],
          upper: [expiresAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterWhereClause> expiresAtBetween(
    DateTime? lowerExpiresAt,
    DateTime? upperExpiresAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'expiresAt',
          lower: [lowerExpiresAt],
          includeLower: includeLower,
          upper: [upperExpiresAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PhotoEntityQueryFilter
    on QueryBuilder<PhotoEntity, PhotoEntity, QFilterCondition> {
  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'album'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  albumIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'album'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'album',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  albumGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'album',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'album',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'album',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'album',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'album',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'album',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'album',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> albumIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'album', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  albumIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'album', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cardBody'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cardBody'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> cardBodyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cardBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cardBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cardBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> cardBodyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cardBody',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cardBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cardBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cardBody',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> cardBodyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cardBody',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cardBody', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cardBody', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'cardTitle'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'cardTitle'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cardTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cardTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cardTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cardTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cardTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cardTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cardTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cardTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'cardTitle', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  cardTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'cardTitle', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'category'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'category'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> categoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> categoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'category',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'category',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> categoryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'category',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'category', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  dateTakenIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'dateTaken'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  dateTakenIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'dateTaken'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  dateTakenEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'dateTaken', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  dateTakenGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'dateTaken',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  dateTakenLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'dateTaken',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  dateTakenBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'dateTaken',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'displayName'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'displayName'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'displayName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'displayName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'displayName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'displayName', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'entityTokens',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'entityTokens',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'entityTokens',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'entityTokens',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'entityTokens',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'entityTokens',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'entityTokens',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'entityTokens',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'entityTokens', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'entityTokens', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entityTokens', length, true, length, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entityTokens', 0, true, 0, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entityTokens', 0, false, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entityTokens', 0, true, length, include);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'entityTokens', length, include, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  entityTokensLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'entityTokens',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  expiresAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  expiresAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'expiresAt'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  expiresAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'expiresAt', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  expiresAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  expiresAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'expiresAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  expiresAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'expiresAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hasFaceEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasFace', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hasQrEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hasQr', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'hash',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'hash',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'hash',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> hashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'hash', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  hashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'hash', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> heightEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'height', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  heightGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'height',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> heightLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'height',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> heightBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'height',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  indexedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'indexedAt', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  indexedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'indexedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  indexedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'indexedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  indexedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'indexedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  isFavoriteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isFavorite', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> isPinnedEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPinned', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'keywords',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'keywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'keywords',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'keywords', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'keywords', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', length, true, length, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', 0, true, 0, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', 0, false, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', 0, true, length, include);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'keywords', length, include, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  keywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'keywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'latitude'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'latitude'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'latitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'latitude',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'longitude'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'longitude'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  longitudeEqualTo(double? value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'longitude',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'longitude',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mediaIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mediaId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mediaIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mediaId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mediaIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mediaId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mediaIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mediaId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mediaIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mediaId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mediaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mediaId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mediaIdContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mediaId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mediaIdMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mediaId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mediaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mediaId', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mediaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mediaId', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'mimeType'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'mimeType'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mimeTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mimeTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mimeType',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mimeType',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> mimeTypeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mimeType',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'mimeType', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  mimeTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'mimeType', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  modifiedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'modifiedAt'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  modifiedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'modifiedAt'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  modifiedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'modifiedAt', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  modifiedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'modifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  modifiedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'modifiedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  modifiedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'modifiedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  needsDeepOcrEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'needsDeepOcr', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'objects',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'objects',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'objects',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'objects',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'objects',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'objects',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'objects',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'objects',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'objects', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'objects', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'objects', length, true, length, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'objects', 0, true, 0, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'objects', 0, false, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'objects', 0, true, length, include);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'objects', length, include, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  objectsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'objects',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ocrKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ocrKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ocrKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ocrKeywords',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ocrKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ocrKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ocrKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ocrKeywords',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ocrKeywords', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ocrKeywords', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ocrKeywords', length, true, length, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ocrKeywords', 0, true, 0, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ocrKeywords', 0, false, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ocrKeywords', 0, true, length, include);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'ocrKeywords', length, include, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrKeywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ocrKeywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrTextIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'ocrText'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrTextIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'ocrText'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> ocrTextEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'ocrText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrTextGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'ocrText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> ocrTextLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'ocrText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> ocrTextBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'ocrText',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrTextStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'ocrText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> ocrTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'ocrText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> ocrTextContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'ocrText',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> ocrTextMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'ocrText',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'ocrText', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  ocrTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'ocrText', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'path',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'path',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'path',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> pathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'path', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  pathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'path', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'qrPayload'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'qrPayload'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'qrPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'qrPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'qrPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'qrPayload',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'qrPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'qrPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'qrPayload',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'qrPayload',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'qrPayload', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  qrPayloadIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'qrPayload', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'semanticEmbedding',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'semanticEmbedding',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'semanticEmbedding',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'semanticEmbedding',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'semanticEmbedding', length, true, length, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'semanticEmbedding', 0, true, 0, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'semanticEmbedding', 0, false, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'semanticEmbedding', 0, true, length, include);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semanticEmbedding',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  semanticEmbeddingLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'semanticEmbedding',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  sizeBytesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sizeBytes', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  sizeBytesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  sizeBytesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sizeBytes',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  sizeBytesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sizeBytes',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  summaryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'summary'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  summaryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'summary'),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> summaryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  summaryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> summaryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> summaryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'summary',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  summaryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> summaryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> summaryContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'summary',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> summaryMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'summary',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  summaryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'summary', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  summaryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'summary', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'visionKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'visionKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'visionKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'visionKeywords',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'visionKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'visionKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'visionKeywords',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'visionKeywords',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'visionKeywords', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'visionKeywords', value: ''),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'visionKeywords', length, true, length, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'visionKeywords', 0, true, 0, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'visionKeywords', 0, false, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'visionKeywords', 0, true, length, include);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'visionKeywords', length, include, 999999, true);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  visionKeywordsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'visionKeywords',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> widthEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'width', value: value),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition>
  widthGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'width',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> widthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'width',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterFilterCondition> widthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'width',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension PhotoEntityQueryObject
    on QueryBuilder<PhotoEntity, PhotoEntity, QFilterCondition> {}

extension PhotoEntityQueryLinks
    on QueryBuilder<PhotoEntity, PhotoEntity, QFilterCondition> {}

extension PhotoEntityQuerySortBy
    on QueryBuilder<PhotoEntity, PhotoEntity, QSortBy> {
  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByCardBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBody', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByCardBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBody', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByCardTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTitle', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByCardTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTitle', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByDateTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHasFace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFace', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHasFaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFace', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHasQr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasQr', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHasQrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasQr', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByIndexedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedAt', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByIndexedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedAt', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modifiedAt', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modifiedAt', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByNeedsDeepOcr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsDeepOcr', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy>
  sortByNeedsDeepOcrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsDeepOcr', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByOcrText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByOcrTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByQrPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrPayload', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByQrPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrPayload', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortBySizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> sortByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension PhotoEntityQuerySortThenBy
    on QueryBuilder<PhotoEntity, PhotoEntity, QSortThenBy> {
  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByAlbum() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByAlbumDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'album', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByCardBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBody', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByCardBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardBody', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByCardTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTitle', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByCardTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cardTitle', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByDateTakenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTaken', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByExpiresAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expiresAt', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHasFace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFace', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHasFaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFace', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHasQr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasQr', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHasQrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasQr', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hash', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByIndexedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedAt', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByIndexedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedAt', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByIsFavoriteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFavorite', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByMediaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByMediaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mediaId', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByMimeType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByMimeTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mimeType', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modifiedAt', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByModifiedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'modifiedAt', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByNeedsDeepOcr() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsDeepOcr', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy>
  thenByNeedsDeepOcrDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needsDeepOcr', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByOcrText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByOcrTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocrText', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'path', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByQrPayload() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrPayload', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByQrPayloadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'qrPayload', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenBySizeBytesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sizeBytes', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenBySummary() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenBySummaryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'summary', Sort.desc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.asc);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QAfterSortBy> thenByWidthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'width', Sort.desc);
    });
  }
}

extension PhotoEntityQueryWhereDistinct
    on QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> {
  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByAlbum({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'album', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByCardBody({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardBody', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByCardTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cardTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByCategory({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByDateTaken() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTaken');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByDisplayName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByEntityTokens() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityTokens');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByExpiresAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expiresAt');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByHasFace() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasFace');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByHasQr() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasQr');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByHash({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByIndexedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indexedAt');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByIsFavorite() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFavorite');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'keywords');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByMediaId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mediaId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByMimeType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mimeType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByModifiedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'modifiedAt');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByNeedsDeepOcr() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needsDeepOcr');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByObjects() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'objects');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByOcrKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ocrKeywords');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByOcrText({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ocrText', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByPath({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'path', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByQrPayload({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'qrPayload', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct>
  distinctBySemanticEmbedding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'semanticEmbedding');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctBySizeBytes() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sizeBytes');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctBySummary({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'summary', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByVisionKeywords() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'visionKeywords');
    });
  }

  QueryBuilder<PhotoEntity, PhotoEntity, QDistinct> distinctByWidth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'width');
    });
  }
}

extension PhotoEntityQueryProperty
    on QueryBuilder<PhotoEntity, PhotoEntity, QQueryProperty> {
  QueryBuilder<PhotoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> albumProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'album');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> cardBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardBody');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> cardTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cardTitle');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<PhotoEntity, DateTime?, QQueryOperations> dateTakenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTaken');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<PhotoEntity, List<String>, QQueryOperations>
  entityTokensProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityTokens');
    });
  }

  QueryBuilder<PhotoEntity, DateTime?, QQueryOperations> expiresAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expiresAt');
    });
  }

  QueryBuilder<PhotoEntity, bool, QQueryOperations> hasFaceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasFace');
    });
  }

  QueryBuilder<PhotoEntity, bool, QQueryOperations> hasQrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasQr');
    });
  }

  QueryBuilder<PhotoEntity, String, QQueryOperations> hashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hash');
    });
  }

  QueryBuilder<PhotoEntity, int, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<PhotoEntity, DateTime, QQueryOperations> indexedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indexedAt');
    });
  }

  QueryBuilder<PhotoEntity, bool, QQueryOperations> isFavoriteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFavorite');
    });
  }

  QueryBuilder<PhotoEntity, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<PhotoEntity, List<String>, QQueryOperations> keywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'keywords');
    });
  }

  QueryBuilder<PhotoEntity, double?, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<PhotoEntity, double?, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<PhotoEntity, String, QQueryOperations> mediaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mediaId');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> mimeTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mimeType');
    });
  }

  QueryBuilder<PhotoEntity, DateTime?, QQueryOperations> modifiedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'modifiedAt');
    });
  }

  QueryBuilder<PhotoEntity, bool, QQueryOperations> needsDeepOcrProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needsDeepOcr');
    });
  }

  QueryBuilder<PhotoEntity, List<String>, QQueryOperations> objectsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'objects');
    });
  }

  QueryBuilder<PhotoEntity, List<String>, QQueryOperations>
  ocrKeywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ocrKeywords');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> ocrTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ocrText');
    });
  }

  QueryBuilder<PhotoEntity, String, QQueryOperations> pathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'path');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> qrPayloadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'qrPayload');
    });
  }

  QueryBuilder<PhotoEntity, List<double>, QQueryOperations>
  semanticEmbeddingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'semanticEmbedding');
    });
  }

  QueryBuilder<PhotoEntity, int, QQueryOperations> sizeBytesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sizeBytes');
    });
  }

  QueryBuilder<PhotoEntity, String?, QQueryOperations> summaryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'summary');
    });
  }

  QueryBuilder<PhotoEntity, List<String>, QQueryOperations>
  visionKeywordsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'visionKeywords');
    });
  }

  QueryBuilder<PhotoEntity, int, QQueryOperations> widthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'width');
    });
  }
}
