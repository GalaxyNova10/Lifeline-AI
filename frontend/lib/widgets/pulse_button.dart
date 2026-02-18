import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// SOS Emergency Pulse Button — Triple concentric ripple rings
/// with spring-back press effect and pulsing gradient center.
class PulseButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final double size;
  final String label;
  final Color color;
  final IconData icon;

  const PulseButton({
    super.key,
    this.onPressed,
    this.size = 140,
    this.label = 'SOS',
    this.color = AppColors.critical,
    this.icon = Icons.emergency,
  });

  @override
  State<PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<PulseButton>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();

    // Continuous triple ripple
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Press spring-back
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  double _ripplePhase(double offset) {
    final v = (_rippleController.value + offset) % 1.0;
    return v;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_rippleController, _pressAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pressAnimation.value,
            child: SizedBox(
              width: widget.size * 1.8,
              height: widget.size * 1.8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple 1
                  _buildRipple(_ripplePhase(0.0)),
                  // Ripple 2
                  _buildRipple(_ripplePhase(0.33)),
                  // Ripple 3
                  _buildRipple(_ripplePhase(0.66)),

                  // Center button
                  Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          widget.color,
                          AppColors.primaryEnd,
                          widget.color.withValues(alpha: 0.8),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Layer 1: The Massive Background Icon
                      Opacity(
                        opacity: 0.2,
                        child: Icon(
                          widget.icon, 
                          size: widget.size, 
                          color: Colors.white,
                        ),
                      ),
                      
                      // Layer 2: The Text (Centered on top)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            widget.label == "Start Check" ? "START\nCHECK" : widget.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRipple(double phase) {
    final scale = 1.0 + phase * 0.5;
    final opacity = (1.0 - phase).clamp(0.0, 0.4);

    return Transform.scale(
      scale: scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.color.withValues(alpha: opacity),
            width: 2.5,
          ),
        ),
      ),
    );
  }
}
