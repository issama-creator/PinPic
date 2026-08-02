import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinpic/services/database_service.dart';
import 'package:pinpic/services/permission_service.dart';
import 'package:pinpic/services/photo_media_service.dart';
import 'package:pinpic/shared/models/app_settings_entity.dart';
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

final searchHistoryRepositoryProvider = Provider<SearchHistoryRepository>((ref) {
  return SearchHistoryRepository(ref.watch(databaseServiceProvider));
});

final appBootstrapProvider = FutureProvider<void>((ref) async {
  final database = ref.watch(databaseServiceProvider);
  await database.initialize();
});

final appSettingsProvider =
    FutureProvider.autoDispose<AppSettingsEntity>((ref) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(settingsRepositoryProvider).getSettings();
});
