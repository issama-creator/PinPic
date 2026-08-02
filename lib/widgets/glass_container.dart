import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.opacity = 0.72,
    this.blur = AppConstants.glassBlur,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double opacity;
  final double blur;

  @override
  Widget build(BuildContext context) {
    final radius =
        borderRadius ?? BorderRadius.circular(AppConstants.cardRadius);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final fill = isLight
        ? AppColors.lightSurfaceGlass.withValues(alpha: opacity)
        : AppColors.surfaceGlass.withValues(alpha: opacity * 0.85);
    final border = isLight ? AppColors.lightBorder : AppColors.border;
    final highlight = isLight
        ? const Color(0x66FFFFFF)
        : AppColors.glassHighlight;
    final fade = isLight
        ? AppColors.lightSurface.withValues(alpha: 0.35)
        : AppColors.surfaceGlass.withValues(alpha: 0.35);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: border),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [highlight, fade],
            ),
          ),
          child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
        ),
      ),
    );
  }
}
