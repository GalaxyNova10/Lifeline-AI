import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Animated circular progress ring with count-up label and
/// color interpolation from green → amber → red based on value.
class ProgressRing extends StatefulWidget {
  final double value; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;
  final String? label;
  final bool showPercentage;
  final bool animate;
  final Duration animationDuration;

  const ProgressRing({
    super.key,
    required this.value,
    this.size = 160,
    this.strokeWidth = 10,
    this.color,
    this.backgroundColor,
    this.label,
    this.showPercentage = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _glowController;
  late Animation<double> _progressAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: widget.value).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _progressController.forward();
    }
    _glowController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _progressAnimation =
          Tween<double>(begin: _progressAnimation.value, end: widget.value)
              .animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.easeOutCubic),
      );
      _progressController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  /// Color interpolation: green → amber → red based on value
  Color get _ringColor {
    if (widget.color != null) return widget.color!;
    final val = widget.value;
    if (val >= 0.8) return AppColors.critical;
    if (val >= 0.5) {
      // Interpolate amber → red
      final t = (val - 0.5) / 0.3;
      return Color.lerp(AppColors.urgent, AppColors.critical, t)!;
    }
    if (val >= 0.3) {
      // Interpolate green → amber
      final t = (val - 0.3) / 0.2;
      return Color.lerp(AppColors.stable, AppColors.urgent, t)!;
    }
    return AppColors.stable;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _glowAnimation]),
      builder: (context, _) {
        final currentValue =
            widget.animate ? _progressAnimation.value : widget.value;
        final percentage = (currentValue * 100).toInt();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow behind ring
              Container(
                width: widget.size * 0.7,
                height: widget.size * 0.7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _ringColor
                          .withValues(alpha: _glowAnimation.value * 0.25),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // Background ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  value: 1.0,
                  color: (widget.backgroundColor ?? Colors.white)
                      .withValues(alpha: 0.08),
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // Foreground ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _RingPainter(
                  value: currentValue,
                  color: _ringColor,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // Center content
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showPercentage)
                    Text(
                      '$percentage%',
                      style: AppTypography.dataBig.copyWith(
                        color: Colors.white,
                        fontSize: widget.size * 0.18,
                      ),
                    ),
                  if (widget.label != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.label!,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white54,
                        fontSize: widget.size * 0.07,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.value,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}
