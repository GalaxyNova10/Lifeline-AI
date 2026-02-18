import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Red warning chip for allergies with icon and label.
class AllergyTag extends StatelessWidget {
  final String allergy;
  final VoidCallback? onRemove;

  const AllergyTag({
    super.key,
    required this.allergy,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.critical.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: AppColors.critical, size: 14),
          const SizedBox(width: 6),
          Text(
            allergy,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.critical,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close,
                  color: AppColors.critical.withValues(alpha: 0.6), size: 14),
            ),
          ],
        ],
      ),
    );
  }
}

/// Condition tag variant — teal/blue for non-allergy conditions
class ConditionTag extends StatelessWidget {
  final String condition;

  const ConditionTag({super.key, required this.condition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.medical_information,
              color: AppColors.info, size: 14),
          const SizedBox(width: 6),
          Text(
            condition,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
        ],
      ),
    );
  }
}
