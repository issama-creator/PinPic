import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/pinpic_logo.dart';
import 'package:pinpic/widgets/pinpic_title.dart';
import 'package:pinpic/widgets/splash_atmosphere.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _startupFailed = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    if (_startupFailed) {
      setState(() => _startupFailed = false);
      ref.invalidate(appBootstrapProvider);
    }
    try {
      await Future.wait([
        ref.read(appBootstrapProvider.future),
        Future<void>.delayed(AppConstants.splashDuration),
      ]);

      if (!mounted) return;

      final settingsRepo = ref.read(settingsRepositoryProvider);

      if (AppConstants.forceFirstLaunchFlow) {
        await settingsRepo.resetFirstLaunchFlow();
        if (!mounted) return;
        context.go(RoutePaths.onboarding);
        return;
      }

      final settings = await settingsRepo.getSettings();

      if (!mounted) return;

      if (!settings.onboardingCompleted) {
        context.go(RoutePaths.onboarding);
        return;
      }

      if (!settings.permissionGranted) {
        context.go(RoutePaths.permission);
        return;
      }

      if (!settings.initialScanCompleted) {
        context.go(RoutePaths.finished);
        return;
      }

      context.go(RoutePaths.home);
    } catch (_) {
      if (mounted) setState(() => _startupFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0E0718),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: SplashAtmosphere(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const PinPicLogo(size: 124)
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .scale(
                          begin: const Offset(0.92, 0.92),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),
                    const SizedBox(height: 26),
                    const PinPicTitle(fontSize: 40)
                        .animate()
                        .fadeIn(delay: 160.ms, duration: 450.ms)
                        .slideY(begin: 0.12, end: 0),
                    const SizedBox(height: 12),
                    Text(
                      AppConstants.appTagline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn(delay: 280.ms, duration: 450.ms),
                    if (_startupFailed) ...[
                      const SizedBox(height: 28),
                      const Text(
                        'Не удалось запустить PinPic',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      TextButton(
                        onPressed: _bootstrap,
                        child: const Text('Повторить'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
