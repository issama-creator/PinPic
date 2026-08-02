import 'package:flutter/material.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/app_scaffold.dart';
import 'package:pinpic/widgets/pinpic_title.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Офлайн')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceCard,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.cloud_off_rounded,
                  size: 44,
                  color: AppColors.cyan,
                ),
              ),
              const SizedBox(height: 24),
              Text.rich(
                TextSpan(
                  style: Theme.of(context).textTheme.headlineSmall,
                  children: [
                    ...PinPicMark.spans(
                      Theme.of(context).textTheme.headlineSmall,
                    ),
                    const TextSpan(text: ' работает полностью офлайн'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Фотографии, индекс и поиск никогда не покидают ваше устройство.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
