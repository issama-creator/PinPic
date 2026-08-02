import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/routes/app_router.dart';
import 'package:pinpic/theme/app_theme.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter();
});

class PinPicApp extends ConsumerWidget {
  const PinPicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
