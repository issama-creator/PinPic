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
import 'package:pinpic/features/search/presentation/search_screen.dart';
import 'package:pinpic/features/settings/presentation/settings_screen.dart';
import 'package:pinpic/features/splash/presentation/splash_screen.dart';
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
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.permission,
        name: 'permission',
        builder: (context, state) => const PermissionScreen(),
      ),
      GoRoute(
        path: RoutePaths.finished,
        name: 'finished',
        builder: (context, state) => const FinishedScreen(),
      ),
      GoRoute(
        path: RoutePaths.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RoutePaths.results,
        name: 'results',
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return ResultsScreen(query: query);
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
