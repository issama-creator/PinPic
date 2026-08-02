import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinpic/core/constants/app_constants.dart';
import 'package:pinpic/core/providers/core_providers.dart';
import 'package:pinpic/routes/route_paths.dart';
import 'package:pinpic/theme/app_colors.dart';
import 'package:pinpic/widgets/gradient_button.dart';
import 'package:pinpic/widgets/pinpic_title.dart';

/// Shared onboarding visual language (screen 1 + 2).
abstract final class _OnboardingStyle {
  static const bg = Color(0xFF050510);

  static const titleGradient = LinearGradient(
    colors: [
      Color(0xFFB56CFF),
      Color(0xFF6B8CFF),
      Color(0xFF3DD7FF),
    ],
  );

  static const glassFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xEB2A1B45),
      Color(0xE0151028),
    ],
  );
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  static const _pageCount = 2;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < _pageCount - 1) {
      await _controller.nextPage(
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    await ref.read(settingsRepositoryProvider).markOnboardingCompleted();
    if (!mounted) return;
    context.go(RoutePaths.permission);
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
        backgroundColor: _OnboardingStyle.bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView(
              controller: _controller,
              onPageChanged: (value) => setState(() => _page = value),
              children: const [
                _SmartSearchPage(),
                _PrivacyPage(),
              ],
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Dots(activeIndex: _page, count: _pageCount),
                      const SizedBox(height: 12),
                      GradientButton(
                        label: _page == _pageCount - 1 ? 'Начать' : 'Далее',
                        onPressed: _next,
                        height: 56,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmartSearchPage extends StatelessWidget {
  const _SmartSearchPage();

  static const _bgAsset = 'images/bgcunb/onboarding_search.png';

  // Asymmetric scatter around the phone — closer to center.
  static const _tags = [
    _TagData(
      'Паспорт',
      Alignment(-0.61, -0.22),
      rotation: -0.06,
      scale: 0.94,
    ),
    _TagData(
      'Пароли Wi-Fi',
      Alignment(0.59, -0.28),
      rotation: 0.05,
      scale: 0.98,
    ),
    _TagData(
      'Билеты',
      Alignment(-0.65, 0.04),
      rotation: 0.04,
      scale: 1.0,
    ),
    _TagData(
      'QR-код',
      Alignment(0.61, 0.08),
      rotation: -0.05,
      scale: 0.96,
    ),
    _TagData(
      'Визитка',
      Alignment(-0.58, 0.36),
      rotation: -0.03,
      scale: 0.97,
    ),
    _TagData(
      'Скриншот',
      Alignment(0.58, 0.42),
      rotation: 0.06,
      scale: 1.0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Image.asset(
          _bgAsset,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Color(0xCC050510),
                Color(0x66050510),
                Colors.transparent,
              ],
              stops: [0.0, 0.35, 0.75],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [
                Color(0xE6050510),
                Color(0x66050510),
                Colors.transparent,
              ],
              stops: [0.0, 0.28, 0.55],
            ),
          ),
        ),
        ..._tags.asMap().entries.map((entry) {
          final index = entry.key;
          final tag = entry.value;
          final fromLeft = tag.alignment.x < 0;
          return Align(
            alignment: tag.alignment,
            child: Transform.rotate(
              angle: tag.rotation,
              child: Transform.scale(
                scale: tag.scale,
                child: _FloatingTag(label: tag.label)
                    .animate()
                    .fadeIn(
                      delay: (120 + 90 * index).ms,
                      duration: 700.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideX(
                      begin: fromLeft ? -0.35 : 0.35,
                      end: 0,
                      delay: (120 + 90 * index).ms,
                      duration: 750.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .animate(
                      delay: (900 + 90 * index).ms,
                      onPlay: (controller) =>
                          controller.repeat(reverse: true),
                    )
                    .moveY(
                      begin: 0,
                      end: index.isEven ? -6 : 6,
                      duration: (2200 + 200 * index).ms,
                      curve: Curves.easeInOut,
                    ),
              ),
            ),
          );
        }),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 36, 28, 120),
            child: Column(
              children: [
                const _OnboardingHeroText()
                    .animate()
                    .fadeIn(duration: 900.ms, curve: Curves.easeOutCubic)
                    .slideY(
                      begin: 0.06,
                      end: 0,
                      duration: 900.ms,
                      curve: Curves.easeOutCubic,
                    ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TagData {
  const _TagData(
    this.label,
    this.alignment, {
    this.rotation = 0,
    this.scale = 1,
  });

  final String label;
  final Alignment alignment;
  final double rotation;
  final double scale;
}

class _FloatingTag extends StatelessWidget {
  const _FloatingTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _OnboardingStyle.glassFill,
        border: Border.all(
          color: const Color(0xFF9B6CFF).withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.1,
            ),
      ),
    );
  }
}

class _OnboardingHeroText extends StatelessWidget {
  const _OnboardingHeroText();

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontSize: 38,
          fontWeight: FontWeight.w800,
          height: 1.12,
          letterSpacing: -0.6,
          color: Colors.white,
          shadows: [
            Shadow(
              color: AppColors.purple.withValues(alpha: 0.35),
              blurRadius: 18,
            ),
          ],
        );

    final subtitleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.45,
          letterSpacing: 0.1,
          color: const Color(0xFFB7B7C8),
        );

    return Column(
      children: [
        Text(
          'Не можете',
          textAlign: TextAlign.center,
          style: titleStyle,
        ),
        const SizedBox(height: 2),
        Text.rich(
          TextSpan(
            style: titleStyle,
            children: [
              const TextSpan(text: 'найти '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (bounds) =>
                      _OnboardingStyle.titleGradient.createShader(bounds),
                  child: Text(
                    'фото?',
                    style: titleStyle?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 56),
        Text.rich(
          TextSpan(
            style: subtitleStyle,
            children: [
              const TextSpan(text: 'Просто опишите, что ищете —\n'),
              ...PinPicMark.spans(subtitleStyle),
              const TextSpan(text: ' найдёт это в вашей галерее.'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  const _PrivacyPage();

  static const _features = [
    (
      icon: Icons.lock_rounded,
      title: '100% приватность',
      text: 'Все данные остаются только на вашем устройстве.',
      glow: Color(0xFF8B5CFF),
    ),
    (
      icon: Icons.cloud_off_rounded,
      title: 'Работает офлайн',
      text: 'Без интернета и без загрузки фото в облако.',
      glow: Color(0xFF6B8CFF),
    ),
    (
      icon: Icons.bolt_rounded,
      title: 'Мгновенный поиск',
      text: 'Находит нужное за секунды.',
      glow: Color(0xFF3DD7FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          height: 0.94,
          letterSpacing: -0.6,
          color: Colors.white,
        );

    final subtitleStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.4,
          letterSpacing: 0.1,
          color: const Color(0xFFB7B7C8),
        );

    return ColoredBox(
      color: _OnboardingStyle.bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Flat dark base — no decorative rings / purple blobs.
          const ColoredBox(color: _OnboardingStyle.bg),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;
                final heroTop = (height * 0.03).clamp(18.0, 28.0) + 20;
                final cardsTop =
                    (height * 0.50).clamp(390.0, 430.0) + 20;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: heroTop,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              'Всё под',
                              textAlign: TextAlign.center,
                              style: titleStyle,
                            ),
                            ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: (bounds) => _OnboardingStyle
                                  .titleGradient
                                  .createShader(bounds),
                              child: Text(
                                'контролем',
                                textAlign: TextAlign.center,
                                style:
                                    titleStyle?.copyWith(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 26),
                            const _PrivacyLogo()
                                .animate()
                                .fadeIn(
                                  duration: 400.ms,
                                  curve: Curves.easeOutCubic,
                                )
                                .scale(
                                  begin: const Offset(0.92, 0.92),
                                  end: const Offset(1, 1),
                                  duration: 400.ms,
                                  curve: Curves.easeOutBack,
                                ),
                            const SizedBox(height: 21),
                            Text.rich(
                              TextSpan(
                                style: subtitleStyle,
                                children: [
                                  ...PinPicMark.spans(subtitleStyle),
                                  const TextSpan(
                                    text:
                                        ' ищет локально.\nФото никогда не покидают телефон.',
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: cardsTop,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF121120),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              for (final entry
                                  in _features.asMap().entries) ...[
                                _PrivacyFeatureRow(
                                  icon: entry.value.icon,
                                  title: entry.value.title,
                                  text: entry.value.text,
                                  glow: entry.value.glow,
                                )
                                    .animate()
                                    .fadeIn(
                                      delay: (70 * entry.key).ms,
                                      duration: 480.ms,
                                      curve: Curves.easeOutCubic,
                                    )
                                    .slideY(
                                      begin: 0.08,
                                      end: 0,
                                      delay: (70 * entry.key).ms,
                                      duration: 480.ms,
                                      curve: Curves.easeOutCubic,
                                    ),
                                if (entry.key != _features.length - 1)
                                  Divider(
                                    height: 1,
                                    thickness: 1,
                                    indent: 70,
                                    endIndent: 16,
                                    color: Colors.white
                                        .withValues(alpha: 0.04),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyLogo extends StatelessWidget {
  const _PrivacyLogo();

  static const double _logoSize = 148;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 196,
      height: 164,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.72,
                colors: [
                  Color(0x0A7A5CFF),
                  Color(0x057A5CFF),
                  Colors.transparent,
                ],
                stops: [0, 0.48, 1],
              ),
            ),
            child: SizedBox.expand(),
          ),
          const Positioned(
            left: 18,
            top: 44,
            child: _BrandDot(size: 3),
          ),
          const Positioned(
            right: 21,
            top: 30,
            child: _BrandDot(size: 2),
          ),
          const Positioned(
            right: 26,
            bottom: 28,
            child: _BrandDot(size: 3),
          ),
          Image.asset(
            'images/bgcunb/33.png',
            width: _logoSize,
            height: _logoSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}

class _BrandDot extends StatelessWidget {
  const _BrandDot({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF9B83FF).withValues(alpha: 0.14),
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}

class _PrivacyFeatureRow extends StatelessWidget {
  const _PrivacyFeatureRow({
    required this.icon,
    required this.title,
    required this.text,
    required this.glow,
  });

  final IconData icon;
  final String title;
  final String text;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: glow.withValues(alpha: 0.16),
                border: Border.all(
                  color: glow.withValues(alpha: 0.32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: glow.withValues(alpha: 0.22),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Icon(icon, size: 20, color: glow),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                          height: 1.25,
                          color: const Color(0xFFD0CCDD),
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == activeIndex;
        return AnimatedContainer(
          duration: AppConstants.animationFast,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 8 : 5,
          height: active ? 8 : 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? AppColors.cyan
                : AppColors.textMuted.withValues(alpha: 0.45),
          ),
        );
      }),
    );
  }
}
