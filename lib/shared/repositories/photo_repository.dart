import 'package:isar_community/isar.dart';
import 'package:pinpic/core/errors/exceptions.dart';
import 'package:pinpic/services/category_engine.dart';
import 'package:pinpic/services/database_service.dart';
import 'package:pinpic/shared/models/photo_entity.dart';

class PhotoRepository {
  PhotoRepository(this._database);

  final DatabaseService _database;

  Isar get _isar => _database.isar;

  Future<int> countAll() {
    return _isar.photos.count();
  }

  Future<int> countFavorites() {
    return _isar.photos.filter().isFavoriteEqualTo(true).count();
  }

  Future<List<String>> distinctCategories() async {
    final values = await _isar.photos
        .where()
        .distinctByCategory(caseSensitive: false)
        .categoryProperty()
        .findAll();
    final categories = values
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList()
      ..sort();
    return categories;
  }

  Future<Map<String, int>> categoryCounts() async {
    final photos = await _isar.photos.filter().categoryIsNotNull().findAll();
    final counts = <String, int>{};
    for (final photo in photos) {
      final category = photo.category?.trim();
      if (category == null || category.isEmpty) continue;
      counts[category] = (counts[category] ?? 0) + 1;
    }
    return counts;
  }

  Future<PhotoEntity?> findByMediaId(String mediaId) {
    return _isar.photos.filter().mediaIdEqualTo(mediaId).findFirst();
  }

  Future<List<PhotoEntity>> findNeedingDeepOcr({int limit = 500}) {
    return _isar.photos
        .filter()
        .needsDeepOcrEqualTo(true)
        .limit(limit)
        .findAll();
  }

  Future<List<PhotoEntity>> getAll({int offset = 0, int limit = 40}) {
    return _isar.photos
        .where()
        .sortByDateTakenDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<List<PhotoEntity>> getFavorites({int offset = 0, int limit = 40}) {
    return _isar.photos
        .filter()
        .isFavoriteEqualTo(true)
        .sortByDateTakenDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<List<PhotoEntity>> getPinned({int offset = 0, int limit = 40}) {
    return _isar.photos
        .where()
        .isPinnedEqualTo(true)
        .sortByDateTakenDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<int> countPinned() {
    return _isar.photos.where().isPinnedEqualTo(true).count();
  }

  /// Expired or expiring within [warnWithinDays], soonest first.
  Future<List<PhotoEntity>> getExpiringSoon({
    int warnWithinDays = 15,
    int limit = 24,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final until = today.add(Duration(days: warnWithinDays));
    final photos = await _isar.photos
        .filter()
        .expiresAtIsNotNull()
        .expiresAtLessThan(until, include: true)
        .sortByExpiresAt()
        .limit(limit)
        .findAll();
    return photos;
  }

  Future<List<PhotoEntity>> getWithExpiry({int limit = 200}) {
    return _isar.photos
        .filter()
        .expiresAtIsNotNull()
        .sortByExpiresAt()
        .limit(limit)
        .findAll();
  }

  /// Recently indexed document-family / receipt cards (habit rail).
  Future<List<PhotoEntity>> getRecentDocuments({
    Duration within = const Duration(hours: 48),
    int limit = 24,
  }) async {
    final since = DateTime.now().subtract(within);
    final photos = await _isar.photos
        .filter()
        .indexedAtGreaterThan(since, include: true)
        .sortByIndexedAtDesc()
        .limit(limit * 3)
        .findAll();
    return photos
        .where((photo) {
          final category = photo.category;
          if (category == null) return false;
          return CategoryEngine.documentFamily.contains(category) ||
              category == CategoryEngine.qr;
        })
        .take(limit)
        .toList(growable: false);
  }

  /// Receipts / tickets taken yesterday — second habit cue beyond "I lost something".
  Future<List<PhotoEntity>> getYesterdayDocuments({int limit = 24}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final photos = await _isar.photos
        .filter()
        .dateTakenBetween(
          yesterday,
          today,
          includeLower: true,
          includeUpper: false,
        )
        .sortByDateTakenDesc()
        .limit(limit * 4)
        .findAll();
    return photos
        .where((photo) {
          final category = photo.category;
          if (category == null) return false;
          return category == CategoryEngine.receipts ||
              category == CategoryEngine.tickets ||
              category == CategoryEngine.qr ||
              CategoryEngine.documentFamily.contains(category);
        })
        .take(limit)
        .toList(growable: false);
  }

  /// Small pool for "try this" while indexing — prefer cards with text facts.
  Future<List<PhotoEntity>> getSampleHintCandidates({int limit = 12}) async {
    final recent = await getRecentDocuments(limit: limit);
    if (recent.isNotEmpty) return recent;
    final withText = await _isar.photos
        .filter()
        .ocrTextIsNotNull()
        .sortByIndexedAtDesc()
        .limit(limit * 2)
        .findAll();
    return withText
        .where((photo) => (photo.ocrText?.trim().isNotEmpty ?? false))
        .take(limit)
        .toList(growable: false);
  }

  Future<void> upsert(PhotoEntity photo) async {
    try {
      await _isar.writeTxn(() async {
        final existing = await _isar.photos
            .filter()
            .mediaIdEqualTo(photo.mediaId)
            .findFirst();
        if (existing != null) {
          photo.id = existing.id;
          photo.isFavorite = existing.isFavorite;
          photo.isPinned = existing.isPinned;
        }
        await _isar.photos.put(photo);
      });
    } catch (error) {
      throw DatabaseException(
        'Failed to upsert photo: $error',
        code: 'photo_upsert_failed',
      );
    }
  }

  Future<void> upsertAll(List<PhotoEntity> photos) async {
    if (photos.isEmpty) return;
    try {
      await _isar.writeTxn(() async {
        final existingPhotos = await _isar.photos.getAllByMediaId(
          photos.map((photo) => photo.mediaId).toList(growable: false),
        );
        for (var index = 0; index < photos.length; index++) {
          final photo = photos[index];
          final existing = existingPhotos[index];
          if (existing != null) {
            photo.id = existing.id;
            photo.isFavorite = existing.isFavorite;
            photo.isPinned = existing.isPinned;
          }
        }
        await _isar.photos.putAll(photos);
      });
    } catch (error) {
      throw DatabaseException(
        'Failed to upsert photos: $error',
        code: 'photo_upsert_all_failed',
      );
    }
  }

  Future<void> setFavorite(String mediaId, bool isFavorite) async {
    await _isar.writeTxn(() async {
      final photo = await _isar.photos
          .filter()
          .mediaIdEqualTo(mediaId)
          .findFirst();
      if (photo == null) return;
      photo.isFavorite = isFavorite;
      await _isar.photos.put(photo);
    });
  }

  Future<void> setPinned(String mediaId, bool isPinned) async {
    await _isar.writeTxn(() async {
      final photo = await _isar.photos
          .filter()
          .mediaIdEqualTo(mediaId)
          .findFirst();
      if (photo == null) return;
      photo.isPinned = isPinned;
      await _isar.photos.put(photo);
    });
  }

  Future<void> deleteByMediaId(String mediaId) async {
    await _isar.writeTxn(() async {
      await _isar.photos.filter().mediaIdEqualTo(mediaId).deleteAll();
    });
  }

  Future<Set<String>> existingMediaIds() async {
    final mediaIds = await _isar.photos.where().mediaIdProperty().findAll();
    return mediaIds.toSet();
  }

  Future<Map<String, PhotoEntity>> getByMediaIds(
    Iterable<String> mediaIds,
  ) async {
    final ids = mediaIds.toList(growable: false);
    if (ids.isEmpty) return const {};
    final photos = await _isar.photos.getAllByMediaId(ids);
    return {
      for (final photo in photos)
        if (photo != null) photo.mediaId: photo,
    };
  }

  Future<int> deleteMissingMediaIds(Set<String> deviceMediaIds) async {
    final indexedIds = await existingMediaIds();
    final removed = indexedIds.difference(deviceMediaIds);
    if (removed.isEmpty) return 0;
    return _isar.writeTxn(
      () => _isar.photos.deleteAllByMediaId(removed.toList(growable: false)),
    );
  }

  Future<int> countWithOcr() {
    return _isar.photos.filter().ocrTextIsNotNull().ocrTextIsNotEmpty().count();
  }

  Future<int> countWithObjects() {
    return _isar.photos.filter().objectsIsNotEmpty().count();
  }

  Future<List<String>> suggestKeywords(String prefix, {int limit = 12}) async {
    final needle = prefix.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    final photos = await _isar.photos.where().limit(500).findAll();
    final matches = <String>{};
    for (final photo in photos) {
      for (final keyword in photo.keywords) {
        if (keyword.toLowerCase().startsWith(needle)) {
          matches.add(keyword);
        }
      }
      final category = photo.category;
      if (category != null && category.toLowerCase().startsWith(needle)) {
        matches.add(category);
      }
      if (matches.length >= limit * 3) break;
    }

    final list = matches.toList()..sort();
    return list.take(limit).toList(growable: false);
  }

  Future<Set<String>> keywordVocabulary({int limit = 3000}) async {
    final keywordLists = await _isar.photos
        .where()
        .limit(limit)
        .keywordsProperty()
        .findAll();
    return {
      for (final keywords in keywordLists)
        for (final keyword in keywords)
          if (keyword.trim().isNotEmpty) keyword.toLowerCase(),
    };
  }

  /// Bounded local scan used only by the semantic vector index. Isar does not
  /// have an ANN vector type, so callers ask for a small top-K and keep this
  /// pool bounded; lexical retrieval remains the fast primary path.
  Future<List<PhotoEntity>> semanticCandidatePool({int limit = 2400}) {
    return _isar.photos
        .filter()
        .semanticEmbeddingIsNotEmpty()
        .sortByDateTakenDesc()
        .limit(limit)
        .findAll();
  }

  Future<List<PhotoEntity>> getWithQr({int offset = 0, int limit = 200}) {
    return _isar.photos
        .filter()
        .hasQrEqualTo(true)
        .sortByDateTakenDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<List<PhotoEntity>> searchCandidatesForTokens({
    required Set<String> tokens,
    String? category,
    bool favoritesOnly = false,
    int limit = 600,
  }) async {
    if (tokens.isEmpty) {
      // Quick category tiles pass a category with no free-text query. Query
      // the (indexed) `category` field directly instead of scanning only the
      // most recent `limit` photos overall — otherwise a category whose
      // matches aren't among the newest photos would silently look empty
      // once a library has more photos than the fetch limit.
      if (category != null && category.trim().isNotEmpty) {
        final byCategory = await _isar.photos
            .where()
            .categoryEqualTo(category)
            .findAll();
        byCategory.sort((a, b) {
          final aDate = a.dateTaken ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = b.dateTaken ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });
        final limited = byCategory.length > limit
            ? byCategory.sublist(0, limit)
            : byCategory;
        return _applyFilters(limited, null, favoritesOnly);
      }
      final all = favoritesOnly
          ? await getFavorites(limit: limit)
          : await getAll(limit: limit);
      return _applyFilters(all, category, favoritesOnly);
    }

    final candidates = <String, PhotoEntity>{};
    final perTokenLimit = (limit ~/ tokens.length).clamp(40, limit);
    for (final token in tokens) {
      final exact = await _isar.photos
          .where()
          .keywordsElementEqualTo(token)
          .limit(perTokenLimit)
          .findAll();
      for (final photo in exact) {
        candidates[photo.mediaId] = photo;
      }

      // OCR and vision terms have their own indexed fields. Querying them
      // directly means an OCR-heavy photo is discoverable even if its generic
      // keyword list was capped during indexing.
      final ocrMatches = await _isar.photos
          .where()
          .ocrKeywordsElementEqualTo(token)
          .limit(perTokenLimit)
          .findAll();
      for (final photo in ocrMatches) {
        candidates[photo.mediaId] = photo;
      }
      // entityTokens are also merged into keywords at index time; scan the
      // OCR/keyword hits (and a small recent window) for structured tokens
      // without relying on a separate Isar list index call-site.
      if (candidates.length < limit) {
        final recent = await _isar.photos
            .where()
            .sortByDateTakenDesc()
            .limit(perTokenLimit)
            .findAll();
        for (final photo in recent) {
          if (photo.entityTokens.any(
            (value) => value.toLowerCase() == token,
          )) {
            candidates[photo.mediaId] = photo;
          }
        }
      }

      if (token.length >= 3 && candidates.length < limit) {
        final prefix = await _isar.photos
            .where()
            .keywordsElementStartsWith(token)
            .limit(perTokenLimit)
            .findAll();
        for (final photo in prefix) {
          candidates[photo.mediaId] = photo;
        }
        final ocrPrefix = await _isar.photos
            .where()
            .ocrKeywordsElementStartsWith(token)
            .limit(perTokenLimit)
            .findAll();
        for (final photo in ocrPrefix) {
          candidates[photo.mediaId] = photo;
          if (candidates.length >= limit) break;
        }
      }
      if (candidates.length >= limit) break;
    }

    return _applyFilters(
      candidates.values.take(limit).toList(growable: false),
      category,
      favoritesOnly,
    );
  }

  List<PhotoEntity> _applyFilters(
    List<PhotoEntity> photos,
    String? category,
    bool favoritesOnly,
  ) {
    final normalizedCategory = category?.trim().toLowerCase();
    return photos
        .where((photo) {
          if (favoritesOnly && !photo.isFavorite) return false;
          if (normalizedCategory != null &&
              normalizedCategory.isNotEmpty &&
              (photo.category ?? '').toLowerCase() != normalizedCategory) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }
}
