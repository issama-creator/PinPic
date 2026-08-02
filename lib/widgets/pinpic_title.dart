import 'package:flutter/material.dart';
import 'package:pinpic/theme/app_colors.dart';

/// Brand wordmark: white "Pin" + cyan→purple "Pic".
class PinPicMark extends StatelessWidget {
  const PinPicMark({super.key, this.style, this.textAlign});

  final TextStyle? style;
  final TextAlign? textAlign;

  static const picGradient = LinearGradient(
    colors: [AppColors.cyan, AppColors.purple],
  );

  /// Inline spans for use inside [Text.rich] / [TextSpan] children.
  static List<InlineSpan> spans(TextStyle? style) {
    return [
      TextSpan(text: 'Pin', style: style),
      WidgetSpan(
        alignment: PlaceholderAlignment.baseline,
        baseline: TextBaseline.alphabetic,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => picGradient.createShader(bounds),
          child: Text(
            'Pic',
            style: (style ?? const TextStyle()).copyWith(color: Colors.white),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final base =
        style ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        );

    return Text.rich(TextSpan(children: spans(base)), textAlign: textAlign);
  }
}

class PinPicTitle extends StatelessWidget {
  const PinPicTitle({super.key, this.fontSize = 40});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).textTheme.displayMedium?.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      height: 1.1,
      color: AppColors.textPrimary,
    );

    return PinPicMark(style: base);
  }
}
