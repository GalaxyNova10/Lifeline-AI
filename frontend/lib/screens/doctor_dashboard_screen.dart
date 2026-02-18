import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_card.dart';
import '../providers/user_provider.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  final List<_Patient> _patients = const [
    _Patient("Rahul Verma", 45, "Male", "Cardiac Arrest", 98, "Pending"),
    _Patient("Sarah Jenkins", 29, "Female", "Severe Asthma", 72, "Pending"),
    _Patient("Amit Patel", 60, "Male", "Diabetic Foot", 45, "Admitted"),
    _Patient("John Doe", 32, "Male", "High Fever", 30, "Pending"),
    _Patient("Priya Sharma", 24, "Female", "Migraine", 15, "Pending"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkNavyGradient,
            ),
          ),
          
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  floating: true,
                  expandedHeight: 120.0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                context.watch<UserProvider>().name,
                                style: GoogleFonts.outfit(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Cardiology Specialist",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: AppColors.neonRed,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.logout_rounded, color: AppColors.neonRed),
                              tooltip: 'Logout',
                              onPressed: () {
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        // Stats Grid
                        Row(
                          children: [
                            Expanded(child: _buildStatCard("Pending", "12", AppColors.neonYellow)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard("Critical", "3", AppColors.neonRed)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildStatCard("Total", "45", AppColors.neonBlue)),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        Text(
                          "Patient Queue",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildPatientCard(_patients[index], index),
                      );
                    },
                    childCount: _patients.length,
                  ),
                ),
                
                const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildPatientCard(_Patient p, int index) {
    Color riskColor;
    if (p.riskScore >= 90) {
      riskColor = AppColors.neonRed;
    } else if (p.riskScore >= 50) {
      riskColor = AppColors.neonYellow; // Orange-ish in context usually
    } else {
      riskColor = AppColors.neonBlue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  child: Text(
                    p.name.split(' ').map((e) => e[0]).take(2).join(),
                    style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${p.name}, ${p.age}y",
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        p.condition,
                        style: GoogleFonts.inter(color: Colors.white54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: riskColor.withValues(alpha: 0.1),
                    border: Border.all(color: riskColor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Risk: ${p.riskScore}",
                    style: GoogleFonts.firaCode(color: riskColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neonGreen,
                      side: const BorderSide(color: AppColors.neonGreen),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Admit"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white54,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Defer"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX();
  }
}

class _Patient {
  final String name;
  final int age;
  final String gender;
  final String condition;
  final int riskScore;
  final String status;

  const _Patient(this.name, this.age, this.gender, this.condition, this.riskScore, this.status);
}
