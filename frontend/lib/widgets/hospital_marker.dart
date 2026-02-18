import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Custom map marker bubble with wait-time color coding.
/// Green (<15 min), Amber (15-30), Red (>30 min).
class HospitalMarker extends StatelessWidget {
  final String name;
  final int waitMinutes;
  final String? specialization;
  final bool isSelected;
  final VoidCallback? onTap;

  const HospitalMarker({
    super.key,
    required this.name,
    required this.waitMinutes,
    this.specialization,
    this.isSelected = false,
    this.onTap,
  });

  Color get _color => AppColors.waitColorFor(waitMinutes);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bubble
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? _color.withValues(alpha: 0.25)
                  : AppColors.darkBg1.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _color.withValues(alpha: isSelected ? 0.8 : 0.5),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _color.withValues(alpha: isSelected ? 0.3 : 0.1),
                  blurRadius: isSelected ? 12 : 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$waitMinutes min',
                  style: GoogleFonts.firaCode(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _color,
                  ),
                ),
                if (specialization != null)
                  Text(
                    specialization!,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.white54,
                    ),
                  ),
              ],
            ),
          ),
          // Pointer
          CustomPaint(
            size: const Size(12, 8),
            painter: _TrianglePainter(
              color: _color.withValues(alpha: isSelected ? 0.8 : 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter old) => old.color != color;
}
