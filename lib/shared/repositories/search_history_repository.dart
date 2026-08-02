import 'package:isar_community/isar.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/services/database_service.dart';
import 'package:pinpic/shared/models/search_history_entity.dart';

class SearchHistoryRepository {
  SearchHistoryRepository(this._database);

  final DatabaseService _database;

  Isar get _isar => _database.isar;

  Future<List<SearchHistoryEntity>> getRecent({
    int limit = AppConstants.recentSearchesLimit,
  }) {
    return _isar.searchHistory
        .where()
        .sortBySearchedAtDesc()
        .limit(limit)
        .findAll();
  }

  Future<void> add({
    required String query,
    int resultCount = 0,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return;

    await _isar.writeTxn(() async {
      final existing = await _isar.searchHistory
          .filter()
          .queryEqualTo(normalized, caseSensitive: false)
          .findAll();
      for (final item in existing) {
        await _isar.searchHistory.delete(item.id);
      }

      await _isar.searchHistory.put(
        SearchHistoryEntity.create(
          query: normalized,
          searchedAt: DateTime.now(),
          resultCount: resultCount,
        ),
      );

      final all = await _isar.searchHistory
          .where()
          .sortBySearchedAtDesc()
          .findAll();
      if (all.length > AppConstants.recentSearchesLimit) {
        final overflow = all.skip(AppConstants.recentSearchesLimit);
        for (final item in overflow) {
          await _isar.searchHistory.delete(item.id);
        }
      }
    });
  }

  Future<void> clear() async {
    await _isar.writeTxn(() async {
      await _isar.searchHistory.clear();
    });
  }
}
