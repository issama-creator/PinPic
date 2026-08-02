import 'package:flutter/material.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/app_scaffold.dart';
import 'package:pinpic/widgets/glass_container.dart';
import 'package:pinpic/widgets/pinpic_title.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Приватность')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.shield_rounded, color: AppColors.purple, size: 36),
                  const SizedBox(height: 14),
                  Text(
                    '100% локально',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      style: Theme.of(context).textTheme.bodyLarge,
                      children: [
                        ...PinPicMark.spans(
                          Theme.of(context).textTheme.bodyLarge,
                        ),
                        const TextSpan(
                          text:
                              ' не загружает фотографии на сервер. OCR, объекты, категории и поиск выполняются только на устройстве.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const _PrivacyPoint(
              title: 'Нет облака',
              subtitle: 'Данные не синхронизируются и не отправляются.',
            ),
            const SizedBox(height: 10),
            const _PrivacyPoint(
              title: 'Нет аккаунта',
              subtitle: 'Для работы приложения регистрация не нужна.',
            ),
            const SizedBox(height: 10),
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Builder(
                builder: (context) {
                  final titleStyle = Theme.of(context).textTheme.titleMedium;
                  final bodyStyle = Theme.of(context).textTheme.bodyMedium;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Вы контролируете доступ', style: titleStyle),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          style: bodyStyle,
                          children: [
                            const TextSpan(text: 'Без разрешения на фото '),
                            ...PinPicMark.spans(bodyStyle),
                            const TextSpan(text: ' ничего не индексирует.'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyPoint extends StatelessWidget {
  const _PrivacyPoint({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
