import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Lifeline AI — Typography System
/// Poppins for headings, Inter for body, FiraCode for data, Lato for labels.
class AppTypography {
  AppTypography._();

  // ═══════════════════════════════════════════════
  // HEADINGS — Poppins (Bold, geometric, authority)
  // ═══════════════════════════════════════════════
  static TextStyle displayLarge = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static TextStyle headlineMedium = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleLarge = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static TextStyle titleMedium = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ═══════════════════════════════════════════════
  // BODY — Inter (Clean, readable)
  // ═══════════════════════════════════════════════
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // ═══════════════════════════════════════════════
  // DATA — FiraCode (Monospace for vitals, IDs)
  // ═══════════════════════════════════════════════
  static TextStyle dataDisplay = GoogleFonts.firaCode(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle dataBig = GoogleFonts.firaCode(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  // ═══════════════════════════════════════════════
  // LABELS — Lato (Friendly, greetings)
  // ═══════════════════════════════════════════════
  static TextStyle labelLarge = GoogleFonts.lato(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static TextStyle labelSmall = GoogleFonts.lato(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.0,
  );

  // ═══════════════════════════════════════════════
  // CONTEXTUAL HELPERS (pre-colored)
  // ═══════════════════════════════════════════════

  // White text variants (for dark backgrounds)
  static TextStyle get headingWhite => displayLarge.copyWith(color: AppColors.textLight);
  static TextStyle get headingWhiteMd => headlineMedium.copyWith(color: AppColors.textLight);
  static TextStyle get titleWhite => titleLarge.copyWith(color: AppColors.textLight);
  static TextStyle get bodyWhite => bodyLarge.copyWith(color: AppColors.textLight);
  static TextStyle get bodyWhiteMuted => bodyMedium.copyWith(color: AppColors.textLightMuted);
  static TextStyle get bodyWhiteDim => bodySmall.copyWith(color: AppColors.textLightDim);
  static TextStyle get dataWhite => dataDisplay.copyWith(color: AppColors.textLight);
  static TextStyle get labelWhite => labelLarge.copyWith(color: AppColors.textLightMuted);

  // Dark text variants (for light backgrounds)
  static TextStyle get headingDark => displayLarge.copyWith(color: AppColors.textDark);
  static TextStyle get headingDarkMd => headlineMedium.copyWith(color: AppColors.textDark);
  static TextStyle get titleDark => titleLarge.copyWith(color: AppColors.textDark);
  static TextStyle get bodyDark => bodyLarge.copyWith(color: AppColors.textDark);
  static TextStyle get bodyMuted => bodyMedium.copyWith(color: AppColors.textMuted);
  static TextStyle get labelMuted => labelLarge.copyWith(color: AppColors.textMuted);

  // Accent text
  static TextStyle get dataCritical => dataDisplay.copyWith(color: AppColors.neonRed);
  static TextStyle get dataStable => dataDisplay.copyWith(color: AppColors.neonTeal);
}
