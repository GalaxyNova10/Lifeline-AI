import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Glassmorphic card container with frosted blur, border glow, and variants.
/// The foundation widget for all card-like surfaces in Lifeline AI.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blurRadius;
  final double fillOpacity;
  final double borderOpacity;
  final EdgeInsets? padding;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.blurRadius = 12.0,
    this.fillOpacity = 0.08,
    this.borderOpacity = 0.12,
    this.padding = const EdgeInsets.all(20),
    this.glowColor,
    this.borderRadius,
    this.gradient,
  });

  /// Elevated variant — stronger blur, neon glow shadow
  const GlassCard.elevated({
    super.key,
    required this.child,
    this.blurRadius = 20.0,
    this.fillOpacity = 0.12,
    this.borderOpacity = 0.18,
    this.padding = const EdgeInsets.all(24),
    this.glowColor = AppColors.neonCyan,
    this.borderRadius,
    this.gradient,
  });

  /// Subtle variant — minimal blur for list items
  const GlassCard.subtle({
    super.key,
    required this.child,
    this.blurRadius = 6.0,
    this.fillOpacity = 0.05,
    this.borderOpacity = 0.08,
    this.padding = const EdgeInsets.all(16),
    this.glowColor,
    this.borderRadius,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.borderRadiusMd;

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.12),
                  blurRadius: 30,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: fillOpacity),
                      Colors.white.withValues(alpha: fillOpacity * 0.4),
                    ],
                  ),
              borderRadius: radius,
              border: Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
