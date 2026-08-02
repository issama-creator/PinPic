import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Soft fade + slight horizontal slide — matches onboarding PageView feel.
CustomTransitionPage<T> fadeSlidePage<T>({
  required LocalKey key,
  required Widget child,
  Duration duration = const Duration(milliseconds: 650),
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeInOutCubic,
      );
      final out = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeInOutCubic,
      );

      return FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.35).animate(out),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset.zero,
            end: const Offset(-0.04, 0),
          ).animate(out),
          child: FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        ),
      );
    },
  );
}
