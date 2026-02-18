import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Health stat display card with icon, value, label, and optional
/// trending indicator (up/down arrow with color).
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? accentColor;
  final StatTrend trend;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accentColor,
    this.trend = StatTrend.stable,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppColors.neonCyan;

    return ClipRRect(
      borderRadius: AppSpacing.borderRadiusMd,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.08),
                Colors.white.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon + Trend
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: accent, size: 18),
                  ),
                  const Spacer(),
                  if (trend != StatTrend.stable) _buildTrendIndicator(),
                ],
              ),

              const SizedBox(height: 14),

              // Value
              Text(
                value,
                style: AppTypography.dataBig.copyWith(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 4),

              // Label
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendIndicator() {
    final isUp = trend == StatTrend.up;
    final color = isUp ? AppColors.critical : AppColors.stable;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 14,
          ),
        ],
      ),
    );
  }
}

enum StatTrend { up, down, stable }
