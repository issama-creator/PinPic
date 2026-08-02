import 'package:flutter/material.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/theme/app_colors.dart';

class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.height = 56,
    this.glowBlur = 11,
    this.glowOpacity = 0.22,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final double height;
  final double glowBlur;
  final double glowOpacity;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;
    final radius = BorderRadius.circular(AppConstants.buttonRadius);

    return AnimatedOpacity(
      duration: AppConstants.animationFast,
      opacity: isEnabled ? 1 : 0.45,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.brandGradient,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: glowOpacity),
              blurRadius: glowBlur,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: radius,
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Stack(
                children: [
                  // Inner top highlight — 1px white @ 12%.
                  Positioned(
                    left: 12,
                    right: 12,
                    top: 1,
                    child: IgnorePointer(
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(1),
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
