import 'package:isar_community/isar.dart';

part 'app_settings_entity.g.dart';

@Collection(accessor: 'settings')
class AppSettingsEntity {
  Id id = 0;

  bool onboardingCompleted = false;

  bool permissionRequested = false;

  bool permissionGranted = false;

  bool initialScanCompleted = false;

  int totalPhotosFound = 0;

  int totalIndexed = 0;

  int totalCategories = 0;

  DateTime? lastIndexedAt;

  String localeCode = 'ru';

  bool useLightTheme = false;

  AppSettingsEntity();

  AppSettingsEntity.initial()
    : onboardingCompleted = false,
      permissionRequested = false,
      permissionGranted = false,
      initialScanCompleted = false,
      totalPhotosFound = 0,
      totalIndexed = 0,
      totalCategories = 0,
      localeCode = 'ru',
      useLightTheme = false;
}
