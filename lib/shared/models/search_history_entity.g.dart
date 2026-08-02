// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSearchHistoryEntityCollection on Isar {
  IsarCollection<SearchHistoryEntity> get searchHistory => this.collection();
}

const SearchHistoryEntitySchema = CollectionSchema(
  name: r'SearchHistoryEntity',
  id: -7201285660364201334,
  properties: {
    r'query': PropertySchema(id: 0, name: r'query', type: IsarType.string),
    r'resultCount': PropertySchema(
      id: 1,
      name: r'resultCount',
      type: IsarType.long,
    ),
    r'searchedAt': PropertySchema(
      id: 2,
      name: r'searchedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _searchHistoryEntityEstimateSize,
  serialize: _searchHistoryEntitySerialize,
  deserialize: _searchHistoryEntityDeserialize,
  deserializeProp: _searchHistoryEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'query': IndexSchema(
      id: -3238105102146786367,
      name: r'query',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'query',
          type: IndexType.hash,
          caseSensitive: false,
        ),
      ],
    ),
    r'searchedAt': IndexSchema(
      id: 4437879492455379665,
      name: r'searchedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'searchedAt',
          type: IndexType.value,
          caseSensitive: false,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _searchHistoryEntityGetId,
  getLinks: _searchHistoryEntityGetLinks,
  attach: _searchHistoryEntityAttach,
  version: '3.3.2',
);

int _searchHistoryEntityEstimateSize(
  SearchHistoryEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.query.length * 3;
  return bytesCount;
}

void _searchHistoryEntitySerialize(
  SearchHistoryEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.query);
  writer.writeLong(offsets[1], object.resultCount);
  writer.writeDateTime(offsets[2], object.searchedAt);
}

SearchHistoryEntity _searchHistoryEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SearchHistoryEntity();
  object.id = id;
  object.query = reader.readString(offsets[0]);
  object.resultCount = reader.readLong(offsets[1]);
  object.searchedAt = reader.readDateTime(offsets[2]);
  return object;
}

P _searchHistoryEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _searchHistoryEntityGetId(SearchHistoryEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _searchHistoryEntityGetLinks(
  SearchHistoryEntity object,
) {
  return [];
}

void _searchHistoryEntityAttach(
  IsarCollection<dynamic> col,
  Id id,
  SearchHistoryEntity object,
) {
  object.id = id;
}

extension SearchHistoryEntityQueryWhereSort
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QWhere> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhere>
  anySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'searchedAt'),
      );
    });
  }
}

extension SearchHistoryEntityQueryWhere
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QWhereClause> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
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

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
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

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  queryEqualTo(String query) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'query', value: [query]),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  queryNotEqualTo(String query) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'query',
                lower: [],
                upper: [query],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'query',
                lower: [query],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'query',
                lower: [query],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'query',
                lower: [],
                upper: [query],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  searchedAtEqualTo(DateTime searchedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'searchedAt', value: [searchedAt]),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  searchedAtNotEqualTo(DateTime searchedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [],
                upper: [searchedAt],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [searchedAt],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [searchedAt],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'searchedAt',
                lower: [],
                upper: [searchedAt],
                includeUpper: false,
              ),
            );
      }
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  searchedAtGreaterThan(DateTime searchedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'searchedAt',
          lower: [searchedAt],
          includeLower: include,
          upper: [],
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  searchedAtLessThan(DateTime searchedAt, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'searchedAt',
          lower: [],
          upper: [searchedAt],
          includeUpper: include,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterWhereClause>
  searchedAtBetween(
    DateTime lowerSearchedAt,
    DateTime upperSearchedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.between(
          indexName: r'searchedAt',
          lower: [lowerSearchedAt],
          includeLower: includeLower,
          upper: [upperSearchedAt],
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SearchHistoryEntityQueryFilter
    on
        QueryBuilder<
          SearchHistoryEntity,
          SearchHistoryEntity,
          QFilterCondition
        > {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
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

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
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

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
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

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'query',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'query',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'query',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'query', value: ''),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  queryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'query', value: ''),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  resultCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'resultCount', value: value),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  resultCountGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'resultCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  resultCountLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'resultCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  resultCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'resultCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  searchedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'searchedAt', value: value),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  searchedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'searchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  searchedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'searchedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterFilterCondition>
  searchedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'searchedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension SearchHistoryEntityQueryObject
    on
        QueryBuilder<
          SearchHistoryEntity,
          SearchHistoryEntity,
          QFilterCondition
        > {}

extension SearchHistoryEntityQueryLinks
    on
        QueryBuilder<
          SearchHistoryEntity,
          SearchHistoryEntity,
          QFilterCondition
        > {}

extension SearchHistoryEntityQuerySortBy
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QSortBy> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  sortByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  sortByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  sortByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  sortByResultCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  sortBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  sortBySearchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.desc);
    });
  }
}

extension SearchHistoryEntityQuerySortThenBy
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QSortThenBy> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenByQuery() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenByQueryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'query', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenByResultCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'resultCount', Sort.desc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.asc);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QAfterSortBy>
  thenBySearchedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchedAt', Sort.desc);
    });
  }
}

extension SearchHistoryEntityQueryWhereDistinct
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct> {
  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
  distinctByQuery({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'query', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
  distinctByResultCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'resultCount');
    });
  }

  QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QDistinct>
  distinctBySearchedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchedAt');
    });
  }
}

extension SearchHistoryEntityQueryProperty
    on QueryBuilder<SearchHistoryEntity, SearchHistoryEntity, QQueryProperty> {
  QueryBuilder<SearchHistoryEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SearchHistoryEntity, String, QQueryOperations> queryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'query');
    });
  }

  QueryBuilder<SearchHistoryEntity, int, QQueryOperations>
  resultCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'resultCount');
    });
  }

  QueryBuilder<SearchHistoryEntity, DateTime, QQueryOperations>
  searchedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchedAt');
    });
  }
}
