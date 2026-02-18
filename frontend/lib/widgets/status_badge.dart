import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Medical triage status badge — animated colored pill with
/// optional pulse dot indicator for critical states.
class StatusBadge extends StatefulWidget {
  final TriageStatus status;
  final bool showPulse;

  const StatusBadge({
    super.key,
    required this.status,
    this.showPulse = true,
  });

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.status == TriageStatus.critical && widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StatusBadge old) {
    super.didUpdateWidget(old);
    if (widget.status == TriageStatus.critical && widget.showPulse) {
      if (!_pulseController.isAnimating) _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _color {
    switch (widget.status) {
      case TriageStatus.critical:
        return AppColors.critical;
      case TriageStatus.urgent:
        return AppColors.urgent;
      case TriageStatus.stable:
        return AppColors.stable;
      case TriageStatus.info:
        return AppColors.info;
    }
  }

  String get _label {
    switch (widget.status) {
      case TriageStatus.critical:
        return 'CRITICAL';
      case TriageStatus.urgent:
        return 'URGENT';
      case TriageStatus.stable:
        return 'STABLE';
      case TriageStatus.info:
        return 'INFO';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseOpacity =
            widget.status == TriageStatus.critical && widget.showPulse
                ? 0.15 + _pulseController.value * 0.15
                : 0.15;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: pulseOpacity),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: color.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pulse dot
              if (widget.showPulse &&
                  widget.status == TriageStatus.critical) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(
                            alpha: _pulseController.value * 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                _label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum TriageStatus { critical, urgent, stable, info }
