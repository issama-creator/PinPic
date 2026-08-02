import 'package:isar_community/isar.dart';
import 'package:pinpic/core/errors/exceptions.dart';
import 'package:pinpic/services/database_service.dart';
import 'package:pinpic/shared/models/app_settings_entity.dart';

class SettingsRepository {
  SettingsRepository(this._database);

  final DatabaseService _database;

  Isar get _isar => _database.isar;

  Future<AppSettingsEntity> getSettings() async {
    final settings = await _isar.settings.get(0);
    if (settings != null) return settings;

    final initial = AppSettingsEntity.initial();
    await _isar.writeTxn(() async {
      await _isar.settings.put(initial);
    });
    return initial;
  }

  Future<AppSettingsEntity> update(
    void Function(AppSettingsEntity settings) mutate,
  ) async {
    try {
      late AppSettingsEntity updated;
      await _isar.writeTxn(() async {
        final current =
            await _isar.settings.get(0) ?? AppSettingsEntity.initial();
        mutate(current);
        await _isar.settings.put(current);
        updated = current;
      });
      return updated;
    } catch (error) {
      throw DatabaseException(
        'Failed to update settings: $error',
        code: 'settings_update_failed',
      );
    }
  }

  Future<AppSettingsEntity> resetFirstLaunchFlow() {
    return update((settings) {
      settings.onboardingCompleted = false;
      settings.permissionRequested = false;
      settings.permissionGranted = false;
      settings.initialScanCompleted = false;
      settings.totalPhotosFound = 0;
      settings.totalIndexed = 0;
      settings.totalCategories = 0;
      settings.indexedPipelineVersion = 0;
      settings.lastIndexedAt = null;
    });
  }

  Future<AppSettingsEntity> markOnboardingCompleted() {
    return update((settings) {
      settings.onboardingCompleted = true;
    });
  }

  Future<AppSettingsEntity> markPermission({
    required bool requested,
    required bool granted,
  }) {
    return update((settings) {
      settings.permissionRequested = requested;
      settings.permissionGranted = granted;
    });
  }

  Future<AppSettingsEntity> updateIndexStats({
    required int totalPhotosFound,
    required int totalIndexed,
    required int totalCategories,
    bool initialScanCompleted = false,
    int? indexedPipelineVersion,
  }) {
    return update((settings) {
      settings.totalPhotosFound = totalPhotosFound;
      settings.totalIndexed = totalIndexed;
      settings.totalCategories = totalCategories;
      settings.lastIndexedAt = DateTime.now();
      if (indexedPipelineVersion != null) {
        settings.indexedPipelineVersion = indexedPipelineVersion;
      }
      if (initialScanCompleted) {
        settings.initialScanCompleted = true;
      }
    });
  }
}
