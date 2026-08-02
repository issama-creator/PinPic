import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinpic/services/database_service.dart';
import 'package:pinpic/services/indexing_service.dart';
import 'package:pinpic/services/permission_service.dart';
import 'package:pinpic/services/photo_media_service.dart';
import 'package:pinpic/services/search_service.dart';
import 'package:pinpic/services/thumbnail_cache_service.dart';
import 'package:pinpic/shared/models/app_settings_entity.dart';
import 'package:pinpic/shared/models/index_progress.dart';
import 'package:pinpic/shared/repositories/photo_repository.dart';
import 'package:pinpic/shared/repositories/search_history_repository.dart';
import 'package:pinpic/shared/repositories/settings_repository.dart';

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final photoMediaServiceProvider = Provider<PhotoMediaService>((ref) {
  return PhotoMediaService();
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseServiceProvider));
});

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  return PhotoRepository(ref.watch(databaseServiceProvider));
});

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((
  ref,
) {
  return SearchHistoryRepository(ref.watch(databaseServiceProvider));
});

final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService(
    photoRepository: ref.watch(photoRepositoryProvider),
    historyRepository: ref.watch(searchHistoryRepositoryProvider),
  );
});

final thumbnailCacheProvider = Provider<ThumbnailCacheService>((ref) {
  final cache = ThumbnailCacheService();
  ref.onDispose(cache.clear);
  return cache;
});

final indexingServiceProvider = Provider<IndexingService>((ref) {
  final service = IndexingService(
    mediaService: ref.watch(photoMediaServiceProvider),
    photoRepository: ref.watch(photoRepositoryProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final indexProgressProvider =
    NotifierProvider<IndexProgressNotifier, IndexProgress>(
      IndexProgressNotifier.new,
    );

class IndexProgressNotifier extends Notifier<IndexProgress> {
  StreamSubscription<IndexProgress>? _sub;
  DateTime _lastStatsRefresh = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  IndexProgress build() {
    final service = ref.watch(indexingServiceProvider);
    _sub?.cancel();
    _sub = service.progressStream.listen((value) {
      state = value;
      final now = DateTime.now();
      final terminal =
          value.status == IndexingStatus.completed ||
          value.status == IndexingStatus.failed ||
          value.status == IndexingStatus.paused;
      if (terminal ||
          now.difference(_lastStatsRefresh) >=
              const Duration(milliseconds: 500)) {
        _lastStatsRefresh = now;
        ref.invalidate(appSettingsProvider);
        ref.invalidate(photoStatsProvider);
      }
      if (value.status == IndexingStatus.completed) {
        ref.read(searchServiceProvider).invalidateCaches();
      }
    });
    ref.onDispose(() => _sub?.cancel());
    return service.progress;
  }

  Future<void> start({bool forceFull = false}) {
    return ref.read(indexingServiceProvider).start(forceFull: forceFull);
  }

  void stop() {
    ref.read(indexingServiceProvider).stop();
  }
}

final appBootstrapProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseServiceProvider);
  await database.initialize();
});

final appSettingsProvider = FutureProvider.autoDispose<AppSettingsEntity>((
  ref,
) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(settingsRepositoryProvider).getSettings();
});

final recentSearchesProvider = FutureProvider.autoDispose((ref) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(searchHistoryRepositoryProvider).getRecent(limit: 12);
});

class PhotoStats {
  const PhotoStats({
    required this.photos,
    required this.withOcr,
    required this.withObjects,
    required this.indexed,
    required this.categories,
  });

  final int photos;
  final int withOcr;
  final int withObjects;
  final int indexed;
  final int categories;
}

final photoStatsProvider = FutureProvider.autoDispose<PhotoStats>((ref) async {
  await ref.watch(appBootstrapProvider.future);
  final repo = ref.watch(photoRepositoryProvider);
  final settings = await ref.watch(settingsRepositoryProvider).getSettings();
  return PhotoStats(
    photos: settings.totalPhotosFound,
    withOcr: await repo.countWithOcr(),
    withObjects: await repo.countWithObjects(),
    indexed: settings.totalIndexed,
    categories: settings.totalCategories,
  );
});

final favoritesProvider = FutureProvider.autoDispose((ref) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(photoRepositoryProvider).countFavorites();
});
