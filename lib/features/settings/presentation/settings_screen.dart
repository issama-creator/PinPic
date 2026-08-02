import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/app_scaffold.dart';
import 'package:pinpic/widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, this.embedded = false});

  /// When true, renders only the settings body for use inside Home tabs.
  final bool embedded;

  Future<void> _setLightTheme(WidgetRef ref, bool useLight) async {
    await ref.read(settingsRepositoryProvider).update((settings) {
      settings.useLightTheme = useLight;
    });
    ref.invalidate(appSettingsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final useLight = settingsAsync.asData?.value.useLightTheme ?? false;
    final theme = Theme.of(context);

    final body = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (embedded) ...[
          Text('Настройки', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 16),
        ],
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Фон', style: theme.textTheme.titleMedium),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _ThemePreviewCard(
                        label: 'Тёмный',
                        subtitle: 'Глубокий чёрный',
                        selected: !useLight,
                        preview: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.backgroundGradient,
                          ),
                        ),
                        onTap: () => _setLightTheme(ref, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ThemePreviewCard(
                        label: 'Светлый',
                        subtitle: 'Мягкий белый',
                        selected: useLight,
                        preview: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.lightBackgroundGradient,
                          ),
                        ),
                        onTap: () => _setLightTheme(ref, true),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Приватность'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(RoutePaths.privacy),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cloud_off_outlined),
                title: const Text('Офлайн режим'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(RoutePaths.offline),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Очистить историю поиска'),
                onTap: () async {
                  await ref.read(searchHistoryRepositoryProvider).clear();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('История очищена')),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Переиндексировать всё'),
                subtitle: const Text('Заново распознает теги и категории'),
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Переиндексировать все фото?'),
                      content: const Text(
                        'Это заново распознает текст, объекты и категории '
                        'для всех фото. Может занять некоторое время.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Отмена'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Начать'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  ref
                      .read(indexProgressProvider.notifier)
                      .start(forceFull: true);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Переиндексация запущена'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${AppConstants.appName} · локальный поиск',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );

    if (embedded) return body;

    return AppScaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: SafeArea(child: body),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  const _ThemePreviewCard({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.preview,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final Widget preview;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? AppColors.purple
        : theme.dividerColor.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(height: 72, width: double.infinity, child: preview),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppColors.purple,
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
