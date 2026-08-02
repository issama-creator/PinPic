import 'package:flutter/material.dart';

/// Atmosphere close to the PinPic splash mockup:
/// deep purple field + soft diagonal light, no circular halo behind the logo.
class SplashAtmosphere extends StatelessWidget {
  const SplashAtmosphere({super.key, required this.child});

  final Widget child;

  static const Color _base = Color(0xFF12081F);
  static const Color _mid = Color(0xFF1B0E33);
  static const Color _top = Color(0xFF2B1548);
  static const Color _glow = Color(0xFF7A3CFF);
  static const Color _glowSoft = Color(0xFF5B2BB8);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return ColoredBox(
      color: _base,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.2, -1.0),
                end: Alignment(0.35, 1.0),
                colors: [Color(0xFF3A1B66), _top, _mid, _base],
                stops: [0.0, 0.28, 0.62, 1.0],
              ),
            ),
          ),
          IgnorePointer(
            child: Transform.rotate(
              angle: -0.55,
              child: Align(
                alignment: const Alignment(-0.15, -0.25),
                child: Container(
                  width: size.width * 1.35,
                  height: size.height * 0.55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _glow.withValues(alpha: 0.28),
                        _glowSoft.withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: size.height * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x990E0718),
                      Color(0xFF0E0718),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
