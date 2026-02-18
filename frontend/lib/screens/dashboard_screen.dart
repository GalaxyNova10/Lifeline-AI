
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';

import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulse_button.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/user_provider.dart';
import 'appointment_screen.dart';
import 'history_screen.dart';
import 'map_screen.dart';
import 'health_passport_screen.dart';



/// Dashboard — Patient home hub with health stats, SOS pulse button,
/// quick actions grid, and glassmorphic bottom navigation.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  
  // Interactive State
  String _medName = "Metformin (500mg)";
  TimeOfDay _medTime = const TimeOfDay(hour: 8, minute: 0);
  int _waterGoal = 2000;
  int _waterConsumed = 450;


  @override
  void dispose() {

    super.dispose();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 0. Base Gradient (Fix for transparent SVG)
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.darkNavyGradient,
            ),
          ),
          
          // 1. Mesh Orbs (Premium Depth)
          _buildMeshOrbs(MediaQuery.of(context).size),
          
          // 2. Background SVG (Noise Texture)
          Positioned.fill(
            child: SvgPicture.network(
              'https://grainy-gradients.vercel.app/noise.svg',
              fit: BoxFit.cover,
              placeholderBuilder: (context) => const SizedBox.shrink(),
            ),
          ),
          
          // 2. Main Dashboard UI
          SafeArea(
            child: IndexedStack(
              index: _navIndex,
              children: [
                _buildHomeTab(),
                const MapScreen(),
                const AppointmentScreen(),
                const HistoryScreen(),
                const HealthPassportScreen(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: GlassBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        items: const [
          GlassNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          GlassNavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'Map',
          ),
          GlassNavItem(
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: 'Triage', // "Appointment" might be too long, using Triage or + sign
          ),
          GlassNavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: 'History',
          ),
          GlassNavItem(
            icon: Icons.badge_outlined,
            activeIcon: Icons.badge,
            label: 'ID Card',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Greeting header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: AppTypography.labelWhite,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.watch<UserProvider>().name,
                      style: AppTypography.headingWhiteMd,
                    ),
                  ],
                ),
              ),
              // Notification bell
              // Notification bell removed as per final polish task
              const SizedBox(width: 48), // Spacer to balance the row if needed, or just remove

            ],
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .slideX(begin: -0.05),

          const SizedBox(height: 28),

          // Wellness Gauge Section
          // Patient Health Score Section (Premium UI)
          Container(
            height: 280, // Fixed height constraint for consistency
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05), // Glassmorphism
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Title (Uppercase & Spaced)
                Text(
                  "PATIENT HEALTH SCORE",
                  style: AppTypography.labelWhite.copyWith(
                    color: Colors.white54,
                    letterSpacing: 1.5,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 32),
                
                // Circular Indicator (Premium & Responsive)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate strict diameter, capped at 180 for aesthetics
                      final double diameter = math.min(
                        math.min(constraints.maxWidth, constraints.maxHeight),
                        180.0
                      );
                      
                      const int healthScore = 82; // Mock Data
                      const Color scoreColor = Color(0xFF00E676); // Vibrant Green

                      return Center(
                        child: SizedBox(
                          width: diameter,
                          height: diameter,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Track (Full Circle)
                              const CircularProgressIndicator(
                                value: 1.0, 
                                strokeWidth: 12,
                                color: Colors.white10, // Dark grey track
                                strokeCap: StrokeCap.round, 
                              ),
                              // Value Progress Arc
                              const CircularProgressIndicator(
                                value: healthScore / 100,
                                strokeWidth: 12,
                                color: scoreColor,
                                strokeCap: StrokeCap.round,
                              ),
                              // Score Text (Centered & Fitted)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0), // Inner padding to prevent touching ring
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "$healthScore",
                                      style: GoogleFonts.outfit(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // Footer Status
                const Text(
                  "Excellent Condition",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          const SizedBox(height: 36),

          // SOS Section
          Center(
            child: Column(
              children: [
                Text(
                  'EMERGENCY',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white30,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                PulseButton(
                  onPressed: () => _handleEmergency(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).scale(
              begin: const Offset(0.9, 0.9)),

          const SizedBox(height: 36),

          // Daily Health Focus Section
          Text(
            "Today's Focus",
            style: AppTypography.titleWhite,
          ).animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 16),

          Column(
            children: [
              // Card 1: Morning Meds
              _buildFocusCard(
                context,
                icon: Icons.medication,
                title: "Morning Meds",
                subtitle: "$_medName • After Breakfast",
                accentColor: AppColors.neonRed,
                onTap: _showMedicationDialog,
                action: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neonRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.neonRed.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _medTime.format(context),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonRed,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Card 2: Hydration
              _buildFocusCard(
                context,
                icon: Icons.water_drop,
                title: "Hydration",
                subtitle: "Goal: ${_waterGoal}ml • Current: ${_waterConsumed}ml",
                accentColor: AppColors.neonBlue,
                onTap: _showHydrationDialog,
                progress: (_waterConsumed / _waterGoal).clamp(0.0, 1.0),
                action: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.neonBlue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: AppColors.neonBlue, size: 18),
                ),
              ),

              const SizedBox(height: 12),

              // Card 3: Sleep Schedule
              _buildFocusCard(
                context,
                icon: Icons.bedtime,
                title: "Sleep Schedule",
                subtitle: "Target: 8 Hours • Bedtime: 10:30 PM",
                accentColor: AppColors.neonPurple,
                action: Text(
                  "In 6h",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 700.ms),

          const SizedBox(height: 28),

          // Recent activity
          Text(
            'Recent Activity',
            style: AppTypography.titleWhite,
          ).animate().fadeIn(delay: 800.ms),

          const SizedBox(height: 12),

          ..._buildActivityItems(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildActivityItems() {
    final activities = [
      ('AI Triage Completed', 'Risk Score: 32% — Stable', Icons.check_circle,
          AppColors.stable, '2h ago'),
      ('Vitals Recorded', 'HR: 72 bpm, SpO2: 98%', Icons.monitor_heart,
          AppColors.neonCyan, '5h ago'),
      ('Appointment Set', 'Dr. Smith — Cardiology', Icons.calendar_today,
          AppColors.info, '1d ago'),
    ];

    return activities.asMap().entries.map((entry) {
      final i = entry.key;
      final a = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard.subtle(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: a.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(a.$3, color: a.$4, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.$1,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      a.$2,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                a.$5,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.white30,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (900 + i * 100).ms).slideX(begin: 0.05);
    }).toList();
  }

  void _handleEmergency() {
    // 1. Trigger Notification Service (Simulated)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.white),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("EMERGENCY ALERT SENT", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                const Text("Ambulance dispatched. Locating hospital..."),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.critical,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    // 2. Navigate to Map immediately
    setState(() => _navIndex = 1);
  }
  Widget _buildMeshOrbs(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryStart.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.neonCyan.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showMedicationDialog() {
    TextEditingController nameController = TextEditingController(text: _medName);
    TimeOfDay selectedTime = _medTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Edit Medication", style: AppTypography.titleWhite),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Medicine Name",
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: AppColors.neonRed),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            StatefulBuilder(
              builder: (context, setModalState) => Row(
                children: [
                  Expanded(
                    child: Text(
                      "Time: ${selectedTime.format(context)}",
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (picked != null) {
                        setModalState(() => selectedTime = picked);
                      }
                    },
                    child: const Text("Pick Time", style: TextStyle(color: AppColors.neonRed)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonRed,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    setState(() {
                      _medName = nameController.text;
                      _medTime = selectedTime;
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Reminder set for ${selectedTime.format(context)}"),
                        backgroundColor: AppColors.darkSurface,
                      ),
                    );
                  }
                },
                child: const Text(
                  "Save Reminder",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHydrationDialog() {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Hydration Tracker", style: AppTypography.titleWhite),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "Enter ml (e.g. 250)",
                hintStyle: TextStyle(color: Colors.white30),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonBlue)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAddButton(250),
                _buildQuickAddButton(500),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white10),
            onPressed: () {
              final amount = int.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                setState(() => _waterGoal = amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Set Goal", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonBlue),
            onPressed: () {
              final amount = int.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                setState(() => _waterConsumed += amount);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Log Intake", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(int amount) {
    return InkWell(
      onTap: () {
        setState(() => _waterConsumed += amount);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neonBlue.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text("+$amount ml", style: const TextStyle(color: AppColors.neonBlue)),
      ),
    );
  }

  Widget _buildFocusCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Widget action,
    VoidCallback? onTap,
    double? progress,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
              children: [
                // Icon Box
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                
                const SizedBox(width: 14),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action Widget (Right Side)
                action,
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: accentColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} // End of _DashboardScreenState
