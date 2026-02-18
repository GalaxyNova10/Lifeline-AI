import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Primary CTA button with gradient fill, glow shadow, press-to-scale
/// spring animation, and optional loading state.
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final double height;
  final bool isLoading;
  final Gradient? gradient;
  final BorderRadius? borderRadius;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.height = 56,
    this.isLoading = false,
    this.gradient,
    this.borderRadius,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final grad = widget.gradient ?? AppColors.primaryGradient;
    final radius = widget.borderRadius ?? AppSpacing.borderRadiusMd;
    final isDisabled = widget.onPressed == null;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _scaleController.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _scaleController.reverse();
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => _scaleController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: grad,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryStart.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                        ],
                        Text(
                          widget.label,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
