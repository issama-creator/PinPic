import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/app_router.dart';
import 'package:pinpic/theme/app_theme.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.maybeWhen(
    data: (value) =>
        value.useLightTheme ? ThemeMode.light : ThemeMode.dark,
    orElse: () => ThemeMode.dark,
  );
});

class PinPicApp extends ConsumerWidget {
  const PinPicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
