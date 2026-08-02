import 'package:isar_community/isar.dart';

part 'search_history_entity.g.dart';

@Collection(accessor: 'searchHistory')
class SearchHistoryEntity {
  Id id = Isar.autoIncrement;

  @Index(caseSensitive: false)
  late String query;

  @Index()
  late DateTime searchedAt;

  int resultCount = 0;

  SearchHistoryEntity();

  SearchHistoryEntity.create({
    required this.query,
    required this.searchedAt,
    this.resultCount = 0,
  });
}
