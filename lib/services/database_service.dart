import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/core/errors/exceptions.dart';
import 'package:pinpic/shared/models/app_settings_entity.dart';
import 'package:pinpic/shared/models/photo_entity.dart';
import 'package:pinpic/shared/models/search_history_entity.dart';

class DatabaseService {
  Isar? _isar;

  Isar get isar {
    final instance = _isar;
    if (instance == null || !instance.isOpen) {
      throw const DatabaseException(
        'Isar database is not initialized',
        code: 'db_not_ready',
      );
    }
    return instance;
  }

  bool get isReady => _isar != null && _isar!.isOpen;

  Future<Isar> initialize() async {
    if (isReady) return isar;

    try {
      final directory = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [
          PhotoEntitySchema,
          AppSettingsEntitySchema,
          SearchHistoryEntitySchema,
        ],
        directory: directory.path,
        name: AppConstants.databaseName,
      );

      await _ensureSettings();
      return isar;
    } catch (error) {
      throw DatabaseException(
        'Failed to open Isar database: $error',
        code: 'db_open_failed',
      );
    }
  }

  Future<void> _ensureSettings() async {
    final existing = await isar.settings.get(0);
    if (existing != null) return;

    await isar.writeTxn(() async {
      await isar.settings.put(AppSettingsEntity.initial());
    });
  }

  Future<void> clearAll() async {
    await isar.writeTxn(() async {
      await isar.clear();
      await isar.settings.put(AppSettingsEntity.initial());
    });
  }

  Future<void> close() async {
    final instance = _isar;
    if (instance != null && instance.isOpen) {
      await instance.close();
    }
    _isar = null;
  }
}
