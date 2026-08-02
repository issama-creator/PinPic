// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppSettingsEntityCollection on Isar {
  IsarCollection<AppSettingsEntity> get settings => this.collection();
}

const AppSettingsEntitySchema = CollectionSchema(
  name: r'AppSettingsEntity',
  id: 5506238605616873742,
  properties: {
    r'indexedPipelineVersion': PropertySchema(
      id: 0,
      name: r'indexedPipelineVersion',
      type: IsarType.long,
    ),
    r'initialScanCompleted': PropertySchema(
      id: 1,
      name: r'initialScanCompleted',
      type: IsarType.bool,
    ),
    r'lastIndexedAt': PropertySchema(
      id: 2,
      name: r'lastIndexedAt',
      type: IsarType.dateTime,
    ),
    r'localeCode': PropertySchema(
      id: 3,
      name: r'localeCode',
      type: IsarType.string,
    ),
    r'onboardingCompleted': PropertySchema(
      id: 4,
      name: r'onboardingCompleted',
      type: IsarType.bool,
    ),
    r'permissionGranted': PropertySchema(
      id: 5,
      name: r'permissionGranted',
      type: IsarType.bool,
    ),
    r'permissionRequested': PropertySchema(
      id: 6,
      name: r'permissionRequested',
      type: IsarType.bool,
    ),
    r'totalCategories': PropertySchema(
      id: 7,
      name: r'totalCategories',
      type: IsarType.long,
    ),
    r'totalIndexed': PropertySchema(
      id: 8,
      name: r'totalIndexed',
      type: IsarType.long,
    ),
    r'totalPhotosFound': PropertySchema(
      id: 9,
      name: r'totalPhotosFound',
      type: IsarType.long,
    ),
    r'useLightTheme': PropertySchema(
      id: 10,
      name: r'useLightTheme',
      type: IsarType.bool,
    ),
  },

  estimateSize: _appSettingsEntityEstimateSize,
  serialize: _appSettingsEntitySerialize,
  deserialize: _appSettingsEntityDeserialize,
  deserializeProp: _appSettingsEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _appSettingsEntityGetId,
  getLinks: _appSettingsEntityGetLinks,
  attach: _appSettingsEntityAttach,
  version: '3.3.2',
);

int _appSettingsEntityEstimateSize(
  AppSettingsEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.localeCode.length * 3;
  return bytesCount;
}

void _appSettingsEntitySerialize(
  AppSettingsEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.indexedPipelineVersion);
  writer.writeBool(offsets[1], object.initialScanCompleted);
  writer.writeDateTime(offsets[2], object.lastIndexedAt);
  writer.writeString(offsets[3], object.localeCode);
  writer.writeBool(offsets[4], object.onboardingCompleted);
  writer.writeBool(offsets[5], object.permissionGranted);
  writer.writeBool(offsets[6], object.permissionRequested);
  writer.writeLong(offsets[7], object.totalCategories);
  writer.writeLong(offsets[8], object.totalIndexed);
  writer.writeLong(offsets[9], object.totalPhotosFound);
  writer.writeBool(offsets[10], object.useLightTheme);
}

AppSettingsEntity _appSettingsEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppSettingsEntity();
  object.id = id;
  object.indexedPipelineVersion = reader.readLong(offsets[0]);
  object.initialScanCompleted = reader.readBool(offsets[1]);
  object.lastIndexedAt = reader.readDateTimeOrNull(offsets[2]);
  object.localeCode = reader.readString(offsets[3]);
  object.onboardingCompleted = reader.readBool(offsets[4]);
  object.permissionGranted = reader.readBool(offsets[5]);
  object.permissionRequested = reader.readBool(offsets[6]);
  object.totalCategories = reader.readLong(offsets[7]);
  object.totalIndexed = reader.readLong(offsets[8]);
  object.totalPhotosFound = reader.readLong(offsets[9]);
  object.useLightTheme = reader.readBool(offsets[10]);
  return object;
}

P _appSettingsEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appSettingsEntityGetId(AppSettingsEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appSettingsEntityGetLinks(
  AppSettingsEntity object,
) {
  return [];
}

void _appSettingsEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  AppSettingsEntity object,
) {
  object.id = id;
}

extension AppSettingsEntityQueryWhereSort
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QWhere> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppSettingsEntityQueryWhere
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QWhereClause> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterWhereClause>
  idBetween(
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
}

extension AppSettingsEntityQueryFilter
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  indexedPipelineVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'indexedPipelineVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  indexedPipelineVersionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'indexedPipelineVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  indexedPipelineVersionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'indexedPipelineVersion',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  indexedPipelineVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'indexedPipelineVersion',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  initialScanCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'initialScanCompleted',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIndexedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'lastIndexedAt'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIndexedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'lastIndexedAt'),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIndexedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'lastIndexedAt', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIndexedAtGreaterThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lastIndexedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIndexedAtLessThan(DateTime? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lastIndexedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  lastIndexedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lastIndexedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'localeCode',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'localeCode',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'localeCode',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'localeCode', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  localeCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'localeCode', value: ''),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  onboardingCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'onboardingCompleted', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  permissionGrantedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'permissionGranted', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  permissionRequestedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'permissionRequested', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalCategoriesEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalCategories', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalCategoriesGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalCategories',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalCategoriesLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalCategories',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalCategoriesBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalCategories',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalIndexedEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalIndexed', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalIndexedGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalIndexed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalIndexedLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalIndexed',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalIndexedBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalIndexed',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalPhotosFoundEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'totalPhotosFound', value: value),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalPhotosFoundGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'totalPhotosFound',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalPhotosFoundLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'totalPhotosFound',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  totalPhotosFoundBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'totalPhotosFound',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterFilterCondition>
  useLightThemeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'useLightTheme', value: value),
      );
    });
  }
}

extension AppSettingsEntityQueryObject
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {}

extension AppSettingsEntityQueryLinks
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QFilterCondition> {}

extension AppSettingsEntityQuerySortBy
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QSortBy> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIndexedPipelineVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedPipelineVersion', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByIndexedPipelineVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedPipelineVersion', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByInitialScanCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialScanCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByInitialScanCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialScanCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastIndexedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIndexedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLastIndexedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIndexedAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLocaleCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByLocaleCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByPermissionGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionGranted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByPermissionGrantedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionGranted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByPermissionRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionRequested', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByPermissionRequestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionRequested', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByTotalCategories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCategories', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByTotalCategoriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCategories', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByTotalIndexed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIndexed', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByTotalIndexedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIndexed', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByTotalPhotosFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPhotosFound', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByTotalPhotosFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPhotosFound', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByUseLightTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useLightTheme', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  sortByUseLightThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useLightTheme', Sort.desc);
    });
  }
}

extension AppSettingsEntityQuerySortThenBy
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QSortThenBy> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIndexedPipelineVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedPipelineVersion', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByIndexedPipelineVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'indexedPipelineVersion', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByInitialScanCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialScanCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByInitialScanCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'initialScanCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastIndexedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIndexedAt', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLastIndexedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastIndexedAt', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLocaleCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByLocaleCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localeCode', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByOnboardingCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onboardingCompleted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByPermissionGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionGranted', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByPermissionGrantedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionGranted', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByPermissionRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionRequested', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByPermissionRequestedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'permissionRequested', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByTotalCategories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCategories', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByTotalCategoriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCategories', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByTotalIndexed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIndexed', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByTotalIndexedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalIndexed', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByTotalPhotosFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPhotosFound', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByTotalPhotosFoundDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPhotosFound', Sort.desc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByUseLightTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useLightTheme', Sort.asc);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QAfterSortBy>
  thenByUseLightThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'useLightTheme', Sort.desc);
    });
  }
}

extension AppSettingsEntityQueryWhereDistinct
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct> {
  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByIndexedPipelineVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'indexedPipelineVersion');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByInitialScanCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'initialScanCompleted');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLastIndexedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastIndexedAt');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByLocaleCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localeCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByOnboardingCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onboardingCompleted');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByPermissionGranted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissionGranted');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByPermissionRequested() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'permissionRequested');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByTotalCategories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCategories');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByTotalIndexed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalIndexed');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByTotalPhotosFound() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPhotosFound');
    });
  }

  QueryBuilder<AppSettingsEntity, AppSettingsEntity, QDistinct>
  distinctByUseLightTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'useLightTheme');
    });
  }
}

extension AppSettingsEntityQueryProperty
    on QueryBuilder<AppSettingsEntity, AppSettingsEntity, QQueryProperty> {
  QueryBuilder<AppSettingsEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  indexedPipelineVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'indexedPipelineVersion');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  initialScanCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'initialScanCompleted');
    });
  }

  QueryBuilder<AppSettingsEntity, DateTime?, QQueryOperations>
  lastIndexedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastIndexedAt');
    });
  }

  QueryBuilder<AppSettingsEntity, String, QQueryOperations>
  localeCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localeCode');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  onboardingCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onboardingCompleted');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  permissionGrantedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissionGranted');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  permissionRequestedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'permissionRequested');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  totalCategoriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCategories');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  totalIndexedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalIndexed');
    });
  }

  QueryBuilder<AppSettingsEntity, int, QQueryOperations>
  totalPhotosFoundProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPhotosFound');
    });
  }

  QueryBuilder<AppSettingsEntity, bool, QQueryOperations>
  useLightThemeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'useLightTheme');
    });
  }
}
