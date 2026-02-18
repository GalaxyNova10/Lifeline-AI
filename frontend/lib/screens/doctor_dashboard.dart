import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/stat_card.dart';
import '../widgets/status_badge.dart';

/// Doctor Dashboard — Patient queue, real-time stats,
/// and patient detail expansion.
class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int? _expandedPatient;

  final _patients = const [
    _Patient('Priya Sharma', 23, TriageStatus.critical, 92, 'Chest Pain, SOB',
        '08:32'),
    _Patient(
        'Raj Kumar', 45, TriageStatus.urgent, 68, 'High Fever, Nausea', '08:45'),
    _Patient(
        'Anita Verma', 31, TriageStatus.stable, 28, 'Headache', '09:01'),
    _Patient('James Thomas', 62, TriageStatus.urgent, 75, 'Abdominal Pain',
        '09:14'),
    _Patient('Meena Patel', 28, TriageStatus.stable, 15, 'Fatigue', '09:30'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkNavyGradient),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                  ),
                  child: const Center(
                    child: Icon(Icons.medical_services,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr. Sarah Chen',
                          style: AppTypography.titleWhite),
                      Text('Emergency Medicine',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white38)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.stable.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.stable,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('On Duty',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.stable)),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: const StatCard(
                    icon: FontAwesomeIcons.userGroup,
                    value: '12',
                    label: 'In Queue',
                    accentColor: AppColors.neonCyan,
                  ).animate().fadeIn(delay: 100.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const StatCard(
                    icon: FontAwesomeIcons.triangleExclamation,
                    value: '3',
                    label: 'Critical',
                    accentColor: AppColors.critical,
                  ).animate().fadeIn(delay: 200.ms),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: const StatCard(
                    icon: FontAwesomeIcons.clock,
                    value: '18m',
                    label: 'Avg Wait',
                    accentColor: AppColors.urgent,
                  ).animate().fadeIn(delay: 300.ms),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: const StatCard(
                    icon: FontAwesomeIcons.checkDouble,
                    value: '24',
                    label: 'Seen Today',
                    accentColor: AppColors.stable,
                  ).animate().fadeIn(delay: 400.ms),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Patient queue heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Patient Queue', style: AppTypography.titleWhite),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sort,
                          color: Colors.white38, size: 14),
                      const SizedBox(width: 6),
                      Text('Priority',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.white38)),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 12),

            // Patient list
            ...List.generate(_patients.length, (i) {
              final p = _patients[i];
              final isExpanded = _expandedPatient == i;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => setState(() =>
                      _expandedPatient = isExpanded ? null : i),
                  child: GlassCard.subtle(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Priority indicator
                            Container(
                              width: 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: _statusColor(p.status),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    'Age: ${p.age} • ${p.symptoms}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusBadge(status: p.status),
                                const SizedBox(height: 4),
                                Text(p.arrivalTime,
                                    style: GoogleFonts.firaCode(
                                        fontSize: 10,
                                        color: Colors.white30)),
                              ],
                            ),
                          ],
                        ),

                        // Expanded details
                        if (isExpanded) ...[
                          const SizedBox(height: 16),
                          Divider(
                              color: Colors.white.withValues(alpha: 0.08)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              _DetailItem('Risk Score', '${p.riskScore}%'),
                              _DetailItem('Severity',
                                  p.riskScore > 80 ? 'Critical' : (p.riskScore > 50 ? 'Moderate' : 'Low')),
                              _DetailItem('Wait',
                                  '${(i + 1) * 5} min'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _ActionBtn(
                                  label: 'Admit',
                                  icon: Icons.check_circle,
                                  color: AppColors.stable,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ActionBtn(
                                  label: 'Escalate',
                                  icon: Icons.priority_high,
                                  color: AppColors.critical,
                                  onTap: () {},
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _ActionBtn(
                                  label: 'Notes',
                                  icon: Icons.note_add,
                                  color: AppColors.neonCyan,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (600 + i * 100).ms)
                    .slideY(begin: 0.05),
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Color _statusColor(TriageStatus status) {
    switch (status) {
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
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.white30)),
        const SizedBox(height: 4),
        Text(value,
            style: AppTypography.dataWhite.copyWith(fontSize: 14)),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}

class _Patient {
  final String name;
  final int age;
  final TriageStatus status;
  final int riskScore;
  final String symptoms;
  final String arrivalTime;

  const _Patient(this.name, this.age, this.status, this.riskScore,
      this.symptoms, this.arrivalTime);
}
