import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/shared/models/index_progress.dart';
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
    final progress = ref.watch(indexProgressProvider);
    final formatter = NumberFormat.decimalPattern('ru');

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: settingsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(appSettingsProvider),
                  child: const Text('Не удалось загрузить данные. Повторить'),
                ),
              ),
              data: (settings) {
                final indexing = progress.isRunning;
                final failed = progress.status == IndexingStatus.failed;
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
                          child: Icon(
                            failed
                                ? Icons.refresh_rounded
                                : indexing
                                ? Icons.manage_search_rounded
                                : Icons.check_rounded,
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
                      failed
                          ? 'Индексация прервана'
                          : indexing
                          ? 'Индексируем фото'
                          : 'Готово!',
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
                          TextSpan(
                            text: indexing
                                ? ' уже готов к работе'
                                : failed
                                ? ' продолжит с этого места'
                                : ' готов к работе 🚀',
                          ),
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
                                  '${formatter.format(progress.total > 0 ? progress.total : settings.totalPhotosFound)} фото найдено',
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
                    if (indexing) ...[
                      LinearProgressIndicator(value: progress.fraction),
                      const SizedBox(height: 10),
                      Text(
                        progress.label,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                    ],
                    GradientButton(
                      label: failed ? 'Продолжить индексацию' : 'Открыть поиск',
                      onPressed: () async {
                        if (failed) {
                          await ref
                              .read(indexProgressProvider.notifier)
                              .start();
                          return;
                        }
                        await ref.read(settingsRepositoryProvider).update((
                          value,
                        ) {
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
