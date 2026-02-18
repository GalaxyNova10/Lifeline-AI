import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/allergy_tag.dart';
import '../widgets/flip_card.dart';
import '../providers/user_provider.dart';
import 'role_selection_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';

/// Health Passport (ID Card) — Flip card with patient info front
/// and medical data back, allergies, conditions, QR code.
class HealthPassportScreen extends StatelessWidget {
  const HealthPassportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.darkNavyGradient),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Center(
              child: Text('Health Passport', style: AppTypography.headingWhiteMd),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 8),

            Center(
              child: Text(
                'Tap your card to flip',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 28),

            // Flip card
            SizedBox(
              height: 240,
              child: FlipCard(
                front: _buildFrontCard(user),
                back: _buildBackCard(user),
              ),
            ).animate().fadeIn(delay: 300.ms).scale(
                begin: const Offset(0.9, 0.9)),

            const SizedBox(height: 32),

            // Allergies section
            Text('Allergies', style: AppTypography.titleWhite)
                .animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                AllergyTag(allergy: 'Penicillin'),
                AllergyTag(allergy: 'Sulfonamides'),
                AllergyTag(allergy: 'Latex'),
              ],
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),

            // Conditions section
            Text('Medical Conditions', style: AppTypography.titleWhite)
                .animate().fadeIn(delay: 550.ms),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                ConditionTag(condition: 'Type 2 Diabetes'),
                ConditionTag(condition: 'Hypertension'),
              ],
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 24),

            // Emergency contacts
            Text('Emergency Contacts', style: AppTypography.titleWhite)
                .animate().fadeIn(delay: 650.ms),
            const SizedBox(height: 12),

            GlassCard.subtle(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ContactRow('Raj Kumar (Spouse)', '+91 98765 43210',
                      Icons.phone),
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withValues(alpha: 0.08)),
                  const SizedBox(height: 12),
                  _ContactRow('Dr. Patel (PCP)', '+91 98765 43211',
                      Icons.medical_services),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 24),

            // Recent visits
            Text('Recent Visits', style: AppTypography.titleWhite)
                .animate().fadeIn(delay: 750.ms),
            const SizedBox(height: 12),

            ..._buildVisits(),

            ..._buildVisits(),

            const SizedBox(height: 32),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                   Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: AppColors.critical),
                label: Text(
                  "Log Out",
                  style: GoogleFonts.outfit(
                    color: AppColors.critical,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.critical),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontCard(UserProvider user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2B4A), Color(0xFF0D1B2A)],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.08),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite,
                      color: AppColors.neonCyan, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'LIFELINE AI',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonCyan,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.stable.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'VERIFIED',
                  style: GoogleFonts.firaCode(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.stable,
                  ),
                ),
              ),
            ],
          ),

          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.neonCyan.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.neonCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(Icons.person,
                    color: AppColors.neonCyan, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'ID: LF-2024-002847',
                      style: GoogleFonts.firaCode(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FrontDetail('Blood', user.bloodType),
              _FrontDetail('Age', '${user.age}'),
              _FrontDetail('DOB', '${DateTime.now().year - user.age}'), // Calculated DOB
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(UserProvider user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2B4A), Color(0xFF0D1B2A)],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('MEDICAL DATA',
              style: GoogleFonts.firaCode(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white30,
                  letterSpacing: 2)),
          Column(
            children: [
              _BackRow('Insurance', 'Lifeline Premium'),
              _BackRow('Policy #', 'LF-${user.token?.substring(0, 4) ?? "0000"}'),
              _BackRow('Conditions', user.conditions.isNotEmpty ? user.conditions : "None"),
              _BackRow('Last Visit', 'Today'),
            ],
          ),
          // QR placeholder
          // QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: QrImageView(
                data: jsonEncode({
                  "id": user.token ?? "GUEST",
                  "name": user.name,
                  "emergency": "active"
                }),
                version: QrVersions.auto,
                size: 80.0,
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildVisits() {
    final visits = [
      ('Apollo Hospital', 'Routine Check-up', '12 Jan 2024',
          AppColors.stable),
      ('MIOT International', 'Blood Work', '28 Dec 2023', AppColors.info),
      ('Fortis Malar', 'Cardiology Review', '15 Nov 2023',
          AppColors.urgent),
    ];

    return visits.asMap().entries.map((entry) {
      final i = entry.key;
      final v = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard.subtle(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: v.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.local_hospital, color: v.$4, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.$1,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    Text(v.$2,
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
              Text(v.$3,
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white30)),
            ],
          ),
        ).animate().fadeIn(delay: (800 + i * 100).ms),
      );
    }).toList();
  }
}

class _FrontDetail extends StatelessWidget {
  final String label;
  final String value;

  const _FrontDetail(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(fontSize: 10, color: Colors.white30)),
        Text(value,
            style: GoogleFonts.firaCode(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ],
    );
  }
}

class _BackRow extends StatelessWidget {
  final String label;
  final String value;

  const _BackRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
          Text(value,
              style: GoogleFonts.firaCode(
                  fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String name;
  final String phone;
  final IconData icon;

  const _ContactRow(this.name, this.phone, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text(phone,
                  style: GoogleFonts.firaCode(
                      fontSize: 12, color: Colors.white54)),
            ],
          ),
        ),
        const Icon(Icons.call, color: AppColors.neonCyan, size: 18),
      ],
    );
  }
}
