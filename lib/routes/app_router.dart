import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/features/filters/presentation/filters_screen.dart';
import 'package:pinpic/features/finished/presentation/finished_screen.dart';
import 'package:pinpic/features/home/presentation/home_screen.dart';
import 'package:pinpic/features/offline/presentation/offline_screen.dart';
import 'package:pinpic/features/onboarding/presentation/onboarding_screen.dart';
import 'package:pinpic/features/permission/presentation/permission_screen.dart';
import 'package:pinpic/features/photo_details/presentation/photo_details_screen.dart';
import 'package:pinpic/features/privacy/presentation/privacy_screen.dart';
import 'package:pinpic/features/results/presentation/results_screen.dart';
import 'package:pinpic/features/settings/presentation/settings_screen.dart';
import 'package:pinpic/features/splash/presentation/splash_screen.dart';
import 'package:pinpic/routes/app_page_transitions.dart';
import 'package:pinpic/routes/route_paths.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: 'splash',
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: RoutePaths.permission,
        name: 'permission',
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const PermissionScreen()),
      ),
      GoRoute(
        path: RoutePaths.finished,
        name: 'finished',
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const FinishedScreen()),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        pageBuilder: (context, state) =>
            fadeSlidePage(key: state.pageKey, child: const HomeScreen()),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: 'search',
        redirect: (context, state) => RoutePaths.home,
      ),
      GoRoute(
        path: RoutePaths.results,
        name: 'results',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          final category = state.uri.queryParameters['category'];
          final favoritesOnly = state.uri.queryParameters['fav'] == '1';
          return ResultsScreen(
            query: query,
            category: category,
            favoritesOnly: favoritesOnly,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.photoDetails,
        name: 'photoDetails',
        builder: (context, state) {
          final mediaId = state.pathParameters['mediaId'] ?? '';
          return PhotoDetailsScreen(mediaId: mediaId);
        },
      ),
      GoRoute(
        path: RoutePaths.filters,
        name: 'filters',
        builder: (context, state) => const FiltersScreen(),
      ),
      GoRoute(
        path: RoutePaths.offline,
        name: 'offline',
        builder: (context, state) => const OfflineScreen(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RoutePaths.privacy,
        name: 'privacy',
        builder: (context, state) => const PrivacyScreen(),
      ),
    ],
  );
}
