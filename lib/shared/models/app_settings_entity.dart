import 'package:isar_community/isar.dart';

part 'app_settings_entity.g.dart';

@Collection(accessor: 'settings')
class AppSettingsEntity {
  Id id = 0;

  bool onboardingCompleted = false;

  bool permissionRequested = false;

  bool permissionGranted = false;

  bool initialScanCompleted = false;

  /// Opt-in local reminders for document expiry dates.
  bool expiryRemindersEnabled = false;

  /// Soft-ask for notification permission was already shown once.
  bool expiryReminderPromptShown = false;

  int totalPhotosFound = 0;

  int totalIndexed = 0;

  int totalCategories = 0;

  /// Version of the rules/models that produced the stored search index.
  /// A mismatch triggers one safe migration scan on the next app start.
  int indexedPipelineVersion = 0;

  DateTime? lastIndexedAt;

  String localeCode = 'ru';

  bool useLightTheme = false;

  AppSettingsEntity();

  AppSettingsEntity.initial()
    : onboardingCompleted = false,
      permissionRequested = false,
      permissionGranted = false,
      initialScanCompleted = false,
      expiryRemindersEnabled = false,
      expiryReminderPromptShown = false,
      totalPhotosFound = 0,
      totalIndexed = 0,
      totalCategories = 0,
      indexedPipelineVersion = 0,
      localeCode = 'ru',
      useLightTheme = false;
}
