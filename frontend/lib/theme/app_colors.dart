import 'package:flutter/material.dart';

/// Lifeline AI — Centralized Color System
/// All colors used across the app. Never hardcode colors elsewhere.
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════
  // PRIMARY PALETTE
  // ═══════════════════════════════════════════════
  static const Color primaryStart = Color(0xFFFF512F);
  static const Color primaryEnd = Color(0xFFDD2476);
  static const Color secondary = Color(0xFF1A2980);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryStart, primaryEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════════
  // BACKGROUNDS
  // ═══════════════════════════════════════════════
  static const Color darkBg1 = Color(0xFF0F2027);
  static const Color darkBg2 = Color(0xFF203A43);
  static const Color darkBg3 = Color(0xFF2C5364);
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;
  static const Color darkSurface = Color(0xFF111827);

  static const LinearGradient darkNavyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBg1, darkBg2, darkBg3],
  );

  static const LinearGradient darkDiagonalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBg1, darkBg2, darkBg3],
  );

  static LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.08),
      Colors.white.withValues(alpha: 0.03),
    ],
  );

  static LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      const Color(0xFF1A2D3D).withValues(alpha: 0.8),
      const Color(0xFF0F2027).withValues(alpha: 0.9),
    ],
  );

  static LinearGradient cyanGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      neonCyan.withValues(alpha: 0.15),
      neonCyan.withValues(alpha: 0.02),
    ],
  );

  // ═══════════════════════════════════════════════
  // SEMANTIC (Medical Triage)
  // ═══════════════════════════════════════════════
  static const Color critical = Color(0xFFEF4444);
  static const Color urgent = Color(0xFFF59E0B);
  static const Color stable = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);

  // ═══════════════════════════════════════════════
  // NEON ACCENTS
  // ═══════════════════════════════════════════════
  static const Color neonCyan = Color(0xFF26D0CE);
  static const Color neonTeal = Colors.tealAccent;
  static const Color neonGreen = Colors.greenAccent;
  static const Color neonRed = Colors.redAccent;
  static const Color neonBlue = Colors.blueAccent;
  static const Color neonPurple = Colors.purpleAccent;
  static const Color neonYellow = Colors.yellowAccent;

  // ═══════════════════════════════════════════════
  // TEXT
  // ═══════════════════════════════════════════════
  static const Color textDark = Color(0xFF102A43);
  static const Color textMuted = Color(0xFF627D98);
  static const Color textLight = Colors.white;
  static const Color textLightMuted = Colors.white70;
  static const Color textLightDim = Colors.white54;

  // ═══════════════════════════════════════════════
  // GLASSMORPHISM
  // ═══════════════════════════════════════════════
  static Color glassWhite = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = Colors.white.withValues(alpha: 0.15);
  static Color glassDarkBorder = Colors.white.withValues(alpha: 0.1);
  static Color glassHighlight = Colors.white.withValues(alpha: 0.05);

  // ═══════════════════════════════════════════════
  // EMERGENCY OVERRIDE
  // ═══════════════════════════════════════════════
  static const Color emergencyRed = Color(0xFFEF4444);
  static const Color emergencyBlack = Color(0xFF000000);

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [emergencyRed, Color(0xFF7F1D1D), emergencyBlack],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ═══════════════════════════════════════════════
  // WAIT TIME COLORS (Hospital Map)
  // ═══════════════════════════════════════════════
  static const Color waitLow = Colors.greenAccent;
  static const Color waitMedium = Colors.amberAccent;
  static const Color waitHigh = Colors.redAccent;

  static Color waitColorFor(int minutes) {
    if (minutes < 15) return waitLow;
    if (minutes < 30) return waitMedium;
    return waitHigh;
  }
}
