import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class WellnessGauge extends StatelessWidget {
  final int score;
  final double size;

  const WellnessGauge({
    super.key,
    required this.score,
    this.size = 280,
  });

  Color _getColorForScore(double value) {
    if (value < 40) return AppColors.critical; // Red/Orange
    if (value < 75) return AppColors.urgent;   // Yellow/Amber
    return AppColors.neonCyan;                 // Green/Teal
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final color = _getColorForScore(value);
        
        return Stack(
          alignment: Alignment.center,
          children: [
            // Glow behind
            Container(
              width: size * 0.8,
              height: size * 0.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 60,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            
            // Gauge Painter
            CustomPaint(
              size: Size(size, size * 0.6), // Semicircle + padding
              painter: _GaugePainter(
                value: value,
                max: 100,
                color: color,
              ),
            ),
            
            // Text Content
            Positioned(
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Text(
                    value.toInt().toString(),
                    style: GoogleFonts.outfit(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1,
                      shadows: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Daily Score',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final double max;
  final Color color;

  _GaugePainter({required this.value, required this.max, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85); // Pivot at bottom center
    final radius = size.width * 0.45;
    final strokeWidth = 20.0;
    
    // Draw Background Track (Arc)
    // Start at -200 deg, sweep 220 deg (leave bottom open)
    // Or traditional speedometer: 135 deg to 405 deg (270 sweep)
    // Let's do 180 sweep (semicircle) for dashboard look?
    // User asked "large, semi-circular or circular". Semicircle fits dashboard layout better.
    // Let's do 220 degrees for a dynamic look (start 160, end 20)
    
    const startAngle = -math.pi * 1.2; // Start left-bottom
    const sweepAngle = math.pi * 1.4;  // Sweep to right-bottom (total 252 deg)
    
    final paintTrack = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paintTrack,
    );
    
    // Draw Progress Gradient
    final progressSweep = (value / max) * sweepAngle;
    
    // Gradient shader
    final gradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      colors: [
        AppColors.critical,
        AppColors.urgent,
        AppColors.neonCyan,
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(0), 
      // Note: SweepGradient is full circle. Need to rotate or adjust.
      // Easier to use computed single color or just segments?
      // "Gradient shader that interpolates".
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final paintProgress = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      //..maskFilter = MaskFilter.blur(BlurStyle.solid, 4) // Glowy edge?
      ;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      paintProgress,
    );
    
    // Draw Tip Glow
    // Calculate tip position
    final tipAngle = startAngle + progressSweep;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    
    final paintTip = Paint()
      ..color = color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
    canvas.drawCircle(Offset(tipX, tipY), 6, paintTip);
    
    final paintTipSolid = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(tipX, tipY), 3, paintTipSolid);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
