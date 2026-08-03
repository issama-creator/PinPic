abstract final class AppConstants {
  static const String appName = 'PinPic';
  static const String appTagline =
      'Память телефона. Найдите важную информацию на фото.';
  static const String databaseName = 'pinpic';
  static const int databaseSchemaVersion = 1;

  static const bool forceFirstLaunchFlow = false;

  static const Duration splashDuration = Duration(milliseconds: 1800);
  static const Duration searchDebounce = Duration(milliseconds: 100);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 320);
  static const Duration animationSlow = Duration(milliseconds: 500);

  static const int thumbnailSize = 256;
  static const int previewSize = 512;
  static const int searchPageSize = 40;
  static const int recentSearchesLimit = 20;
  static const int suggestionsLimit = 12;

  static const double glassBlur = 18;
  static const double buttonRadius = 18;
  static const double cardRadius = 16;
  static const double screenPadding = 24;
}
