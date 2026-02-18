import 'package:flutter/material.dart';

/// Lifeline AI — Spacing & Radius Design Tokens
/// Based on 4px base unit system.
class AppSpacing {
  AppSpacing._();

  // ═══════════════════════════════════════════════
  // SPACING (4px base unit)
  // ═══════════════════════════════════════════════
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double hero = 60.0;

  // ═══════════════════════════════════════════════
  // PADDING SHORTCUTS
  // ═══════════════════════════════════════════════
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl =
      EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: 12);

  // ═══════════════════════════════════════════════
  // BORDER RADIUS
  // ═══════════════════════════════════════════════
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 30.0;
  static const double radiusFull = 999.0;

  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusFull =
      BorderRadius.circular(radiusFull);

  // ═══════════════════════════════════════════════
  // ELEVATION / SHADOWS
  // ═══════════════════════════════════════════════
  static List<BoxShadow> shadowSm(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.1),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> shadowMd(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> shadowLg(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.3),
          blurRadius: 30,
          offset: const Offset(0, 15),
        ),
      ];

  static List<BoxShadow> glowShadow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: 40,
          spreadRadius: 5,
        ),
      ];

  static List<BoxShadow> neonGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.6),
          blurRadius: 60,
          spreadRadius: 20,
        ),
      ];
}
