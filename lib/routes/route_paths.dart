abstract final class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String permission = '/permission';
  static const String finished = '/finished';
  static const String home = '/home';
  static const String search = '/search';
  static const String results = '/results';
  static const String photoDetails = '/photo/:mediaId';
  static const String filters = '/filters';
  static const String offline = '/offline';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String scanDocument = '/scan-document';

  static String photoDetailsPath(String mediaId) => '/photo/$mediaId';
}
