import 'package:flutter/material.dart';

abstract final class AppColors {
  /// Flat dark — same base as Home / Favorites.
  static const Color background = Color(0xFF050510);
  static const Color backgroundElevated = Color(0xFF0C0C14);
  static const Color surface = Color(0xFF12121C);
  static const Color surfaceGlass = Color(0x99181824);
  static const Color surfaceCard = Color(0xFF1A1A26);

  /// Soft cool white — not harsh pure white.
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightBackgroundElevated = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF0F2F7);
  static const Color lightSurfaceGlass = Color(0xE6FFFFFF);
  static const Color lightSurfaceCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF12121A);
  static const Color lightTextSecondary = Color(0xFF3A3A48);
  static const Color lightTextMuted = Color(0xFF5C5C6A);
  static const Color lightBorder = Color(0x221A1A22);

  static const Color purple = Color(0xFFB02EFF);
  static const Color purpleDeep = Color(0xFF7B2FFF);
  static const Color blue = Color(0xFF007BFF);
  static const Color cyan = Color(0xFF00D4FF);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8C8);
  static const Color textMuted = Color(0xFF7A7A8C);
  static const Color textLink = Color(0xFFA0A0B8);

  static const Color border = Color(0x33FFFFFF);
  static const Color borderGlow = Color(0x55B02EFF);
  static const Color success = Color(0xFF2EE6A8);
  static const Color error = Color(0xFFFF4D6D);
  static const Color warning = Color(0xFFFFB020);

  static const Color glassHighlight = Color(0x22FFFFFF);
  static const Color overlay = Color(0x99000000);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purple, blue, cyan],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient brandGradientVertical = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, purpleDeep, blue],
  );

  /// Near-flat dark fill (no bright purple band). Matches Favorites / Home.
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF08061A),
      Color(0xFF050510),
      Color(0xFF050510),
      Color(0xFF050510),
    ],
    stops: [0.0, 0.22, 0.7, 1.0],
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF3F0FA),
      Color(0xFFF6F7FB),
      Color(0xFFF8F9FC),
      Color(0xFFF6F7FB),
    ],
    stops: [0.0, 0.35, 0.7, 1.0],
  );

  static const LinearGradient textGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [cyan, purple],
  );
}
