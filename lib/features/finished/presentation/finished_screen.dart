import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/glass_container.dart';
import 'package:pinpic/widgets/gradient_background.dart';
import 'package:pinpic/widgets/gradient_button.dart';
import 'package:pinpic/widgets/pinpic_title.dart';

class FinishedScreen extends ConsumerWidget {
  const FinishedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final formatter = NumberFormat.decimalPattern('ru');

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('$error')),
              data: (settings) {
                return Column(
                  children: [
                    const Spacer(),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.brandGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blue.withValues(alpha: 0.45),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: 450.ms,
                          curve: Curves.easeOutBack,
                        )
                        .fadeIn(),
                    const SizedBox(height: 28),
                    Text(
                      'Готово!',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 10),
                    Text.rich(
                      TextSpan(
                        style: Theme.of(context).textTheme.bodyLarge,
                        children: [
                          ...PinPicMark.spans(
                            Theme.of(context).textTheme.bodyLarge,
                          ),
                          const TextSpan(text: ' готов к работе 🚀'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.photo_rounded,
                                  color: AppColors.cyan,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${formatter.format(settings.totalPhotosFound)} фото найдено',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.grid_view_rounded,
                                  color: AppColors.purple,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${formatter.format(settings.totalCategories)} категорий',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GradientButton(
                      label: 'Открыть поиск',
                      onPressed: () async {
                        await ref
                            .read(settingsRepositoryProvider)
                            .update((value) {
                          value.initialScanCompleted = true;
                          value.onboardingCompleted = true;
                        });
                        ref.invalidate(appSettingsProvider);
                        if (context.mounted) {
                          context.go(RoutePaths.home);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
