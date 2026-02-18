import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Language toggle pill for multilingual voice input selection.
/// Supports English, Tamil, and Hindi with flag emojis.
class LanguagePill extends StatelessWidget {
  final String label;
  final String locale;
  final bool isSelected;
  final ValueChanged<String>? onSelected;

  const LanguagePill({
    super.key,
    required this.label,
    required this.locale,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected?.call(locale),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.neonCyan.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.neonCyan.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.neonCyan : Colors.white54,
          ),
        ),
      ),
    );
  }
}
