import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/shared/models/permission_status_model.dart';
import 'package:pinpic/widgets/gradient_button.dart';
import 'package:pinpic/widgets/pinpic_title.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  static const _bgAsset = 'images/bgcunb/22.png';

  bool _loading = false;

  Future<void> _requestAccess() async {
    setState(() => _loading = true);
    final status = await ref
        .read(permissionServiceProvider)
        .requestPhotoPermission();
    final granted = status.isGranted;

    await ref
        .read(settingsRepositoryProvider)
        .markPermission(requested: true, granted: granted);

    if (!mounted) return;
    setState(() => _loading = false);

    if (granted) {
      final count = await ref
          .read(photoMediaServiceProvider)
          .countDevicePhotos();
      await ref
          .read(settingsRepositoryProvider)
          .updateIndexStats(
            totalPhotosFound: count,
            totalIndexed: 0,
            totalCategories: 0,
          );
      unawaited(ref.read(indexProgressProvider.notifier).start());
      if (!mounted) return;
      context.go(RoutePaths.finished);
      return;
    }

    if (status == PhotoPermissionStatus.permanentlyDenied ||
        status == PhotoPermissionStatus.restricted) {
      final openSettings = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Разрешите доступ в настройках'),
          content: const Text(
            'Android больше не показывает запрос разрешения. Откройте настройки PinPic и разрешите доступ к фото и видео.',
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => context.pop(true),
              child: const Text('Открыть настройки'),
            ),
          ],
        ),
      );
      if (openSettings == true) {
        await ref.read(permissionServiceProvider).openSystemSettings();
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text.rich(
          TextSpan(
            style: const TextStyle(color: Colors.white),
            children: [
              const TextSpan(text: 'Нужен доступ к фото, чтобы '),
              ...PinPicMark.spans(const TextStyle(color: Colors.white)),
              const TextSpan(text: ' мог искать.'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _later() async {
    await ref.read(settingsRepositoryProvider).markOnboardingCompleted();
    await ref
        .read(settingsRepositoryProvider)
        .markPermission(requested: true, granted: false);
    if (!mounted) return;
    context.go(RoutePaths.home);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF050510),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF050510),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _bgAsset,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                child: Stack(
                  children: [
                    Align(
                      alignment: const Alignment(0, -0.12),
                      child:
                          Text(
                                'Разрешите доступ\nк фото',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.displaySmall
                                    ?.copyWith(
                                      fontSize: 34,
                                      fontWeight: FontWeight.w800,
                                      height: 1.05,
                                      letterSpacing: -0.5,
                                      color: Colors.white,
                                    ),
                              )
                              .animate()
                              .fadeIn(
                                duration: 700.ms,
                                curve: Curves.easeOutCubic,
                              )
                              .slideY(
                                begin: 0.05,
                                end: 0,
                                duration: 700.ms,
                                curve: Curves.easeOutCubic,
                              ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Soft scrim so copy stays readable over photo tiles.
                          IgnorePointer(
                            child: Container(
                              height: 320,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0xB3050510),
                                    Color(0xF2050510),
                                  ],
                                  stops: [0.0, 0.38, 1.0],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: const TextStyle(
                                      fontSize: 17,
                                      height: 1.45,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFFE4E0F0),
                                      shadows: [
                                        Shadow(
                                          color: Color(0x99050510),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    children: [
                                      const TextSpan(text: 'Чтобы '),
                                      ...PinPicMark.spans(
                                        const TextStyle(
                                          fontSize: 17,
                                          height: 1.45,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFFE4E0F0),
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ' мог искать, нужен доступ\nк вашей галерее.',
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ).animate().fadeIn(
                                  delay: 180.ms,
                                  duration: 700.ms,
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Данные остаются на устройстве.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    height: 1.4,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFFE4E0F0),
                                    shadows: [
                                      Shadow(
                                        color: Color(0x99050510),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(
                                  delay: 200.ms,
                                  duration: 700.ms,
                                ),
                                const SizedBox(height: 18),
                                GradientButton(
                                  label: _loading
                                      ? 'Запрос доступа...'
                                      : 'Разрешить доступ',
                                  onPressed: _loading ? null : _requestAccess,
                                  height: 56,
                                ).animate().fadeIn(
                                  delay: 260.ms,
                                  duration: 700.ms,
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: _loading ? null : _later,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Позже',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFFD0CCD8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
