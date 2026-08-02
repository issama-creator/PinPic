import 'package:flutter/material.dart';
import 'package:pinpic/theme/app_colors.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient = AppColors.backgroundGradient,
  });

  final Widget child;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    if (isLight) {
      return DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppColors.lightBackgroundGradient,
        ),
        child: child,
      );
    }

    // Dark theme: flat fill like Favorites / Home — no bright purple band.
    return ColoredBox(color: AppColors.background, child: child);
  }
}
