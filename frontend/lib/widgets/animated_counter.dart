import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated counting number widget that tweens from 0 to target value.
/// Used for risk scores, stats, and counters.
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String? suffix;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.suffix,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      builder: (context, val, _) {
        final display = val == val.roundToDouble()
            ? val.toInt().toString()
            : val.toStringAsFixed(1);
        return Text(
          '$display${suffix ?? ''}',
          style: style ??
              GoogleFonts.firaCode(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        );
      },
    );
  }
}
