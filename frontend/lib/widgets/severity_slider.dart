import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Custom gradient slider for pain severity (1-10) with
/// gradient track, haptic feedback, and colored thumb.
class SeveritySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  const SeveritySlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 1,
    this.max = 10,
  });

  Color get _thumbColor {
    final norm = (value - min) / (max - min);
    if (norm >= 0.8) return AppColors.critical;
    if (norm >= 0.5) return AppColors.urgent;
    return AppColors.stable;
  }

  String get _label {
    if (value <= 3) return 'Mild';
    if (value <= 6) return 'Moderate';
    if (value <= 8) return 'Severe';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pain Level',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _thumbColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${value.toInt()} — $_label',
                style: GoogleFonts.firaCode(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _thumbColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _thumbColor,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: _thumbColor,
            overlayColor: _thumbColor.withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
          ),
        ),
      ],
    );
  }
}
