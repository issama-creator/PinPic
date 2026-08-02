import 'package:isar_community/isar.dart';
import 'package:pinpic/core/errors/exceptions.dart';
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
    final photos = await _isar.photos.filter().categoryIsNotNull().findAll();
    final categories = photos
        .map((photo) => photo.category)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return categories;
  }

  Future<PhotoEntity?> findByMediaId(String mediaId) {
    return _isar.photos.filter().mediaIdEqualTo(mediaId).findFirst();
  }

  Future<PhotoEntity?> findByHash(String hash) {
    return _isar.photos.filter().hashEqualTo(hash).findFirst();
  }

  Future<List<PhotoEntity>> getAll({
    int offset = 0,
    int limit = 40,
  }) {
    return _isar.photos
        .where()
        .sortByDateTakenDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<List<PhotoEntity>> getFavorites({
    int offset = 0,
    int limit = 40,
  }) {
    return _isar.photos
        .filter()
        .isFavoriteEqualTo(true)
        .sortByDateTakenDesc()
        .offset(offset)
        .limit(limit)
        .findAll();
  }

  Future<void> upsert(PhotoEntity photo) async {
    try {
      await _isar.writeTxn(() async {
        final existing =
            await _isar.photos.filter().mediaIdEqualTo(photo.mediaId).findFirst();
        if (existing != null) {
          photo.id = existing.id;
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
        for (final photo in photos) {
          final existing = await _isar.photos
              .filter()
              .mediaIdEqualTo(photo.mediaId)
              .findFirst();
          if (existing != null) {
            photo.id = existing.id;
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
      final photo =
          await _isar.photos.filter().mediaIdEqualTo(mediaId).findFirst();
      if (photo == null) return;
      photo.isFavorite = isFavorite;
      await _isar.photos.put(photo);
    });
  }

  Future<void> deleteByMediaId(String mediaId) async {
    await _isar.writeTxn(() async {
      await _isar.photos.filter().mediaIdEqualTo(mediaId).deleteAll();
    });
  }

  Future<Set<String>> existingMediaIds() async {
    final photos = await _isar.photos.where().findAll();
    return photos.map((photo) => photo.mediaId).toSet();
  }

  Future<Set<String>> existingHashes() async {
    final photos = await _isar.photos.where().findAll();
    return photos.map((photo) => photo.hash).toSet();
  }
}
