import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import 'login_screen.dart';
import 'doctor_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkNavyGradient,
            ),
          ),

          // Mesh Orbs
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryStart.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryStart.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.heartPulse,
                        size: 48,
                        color: AppColors.neonCyan,
                      ),
                    ).animate().fadeIn(duration: 600.ms).scale(),

                    const SizedBox(height: 24),

                    Text(
                      "Lifeline AI",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    Text(
                      "Advanced Triage & Health Monitoring",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 60),

                    // Role Cards
                    _buildRoleCard(
                      context,
                      title: "I am a Citizen",
                      subtitle: "Access personal health dashboard & triage",
                      icon: FontAwesomeIcons.user,
                      color: AppColors.neonBlue,
                      delay: 400,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                    ),

                    const SizedBox(height: 16),

                    _buildRoleCard(
                      context,
                      title: "I am a Doctor",
                      subtitle: "Manage patients & view medical reports",
                      icon: FontAwesomeIcons.userDoctor,
                      color: AppColors.neonRed,
                      delay: 500,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const DoctorLoginScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int delay,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.3), size: 16),
        ],
      ),
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.1);
  }
}
