import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/progress_ring.dart';
import '../widgets/status_badge.dart';
import 'dashboard_screen.dart';
import 'map_screen.dart';

/// Queue / Results Screen — Risk score radial, triage color band,
/// recommendation cards, and Emergency Override mode (score > 90).
class QueueScreen extends StatefulWidget {
  final List<String> selectedSymptoms;
  final int painLevel;
  final int? triageScore;
  final String? triageRisk;
  final Map<String, dynamic>? triageResult;

  const QueueScreen({
    super.key,
    this.selectedSymptoms = const [],
    this.painLevel = 3,
    this.triageScore,
    this.triageRisk,
    this.triageResult,
  });

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen>
    with TickerProviderStateMixin {
  late double _riskScore;
  bool _isAnalyzing = true;
  bool _isEmergency = false;
  int _countdown = 5;
  Timer? _countdownTimer;
  late AnimationController _emergencyPulse;

  @override
  void initState() {
    super.initState();

    // Use API score if available, otherwise calculate locally
    if (widget.triageScore != null) {
      _riskScore = widget.triageScore!.toDouble().clamp(10, 100);
    } else {
      final baseScore = widget.painLevel * 8.0;
      final symptomScore = widget.selectedSymptoms.length * 5.0;
      _riskScore = (baseScore + symptomScore).clamp(10, 100);
    }

    _emergencyPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Simulate analysis
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _isEmergency = _riskScore > 90;
        });
        if (_isEmergency) {
          _emergencyPulse.repeat(reverse: true);
          _startCountdown();
        }
      }
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() => _countdown--);
        if (_countdown <= 0) {
          t.cancel();
          _dialEmergency();
        }
      }
    });
  }

  void _dialEmergency() {
    // Simulated emergency dial
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emergencyPulse.dispose();
    super.dispose();
  }

  TriageStatus get _triageStatus {
    if (_riskScore > 80) return TriageStatus.critical;
    if (_riskScore > 50) return TriageStatus.urgent;
    return TriageStatus.stable;
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) return _buildAnalyzingUI();
    if (_isEmergency) return _buildEmergencyUI();
    return _buildStandardUI();
  }

  Widget _buildAnalyzingUI() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkNavyGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
                ),
              ),
              const SizedBox(height: 28),
              Text('Analyzing Results...', style: AppTypography.titleWhite)
                  .animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'AI is processing your assessment',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
              ).animate().fadeIn(delay: 200.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyUI() {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _emergencyPulse,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(AppColors.emergencyRed, Colors.black,
                      _emergencyPulse.value * 0.5)!,
                  Colors.black,
                ],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Warning icon
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.white, size: 72)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                        duration: 600.ms,
                      ),

                  const SizedBox(height: 24),

                  Text(
                    '⚠️ CRITICAL CONDITION',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ).animate().fadeIn().shake(duration: 500.ms),

                  const SizedBox(height: 8),

                  Text(
                    'DETECTED',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.critical,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Risk score
                  Text(
                    'Risk Score: ${_riskScore.toInt()}%',
                    style: AppTypography.dataBig.copyWith(
                      color: AppColors.critical,
                      fontSize: 28,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Countdown
                  Text(
                    'Auto-dialing 108 in',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white60),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_countdown',
                    style: GoogleFonts.firaCode(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Navigate to ER
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: 'Navigate to Nearest ER',
                      icon: Icons.navigation,
                      gradient: const LinearGradient(
                        colors: [AppColors.critical, Color(0xFF7F1D1D)],
                      ),
                      onPressed: () {
                        _countdownTimer?.cancel();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapScreen(showBackButton: true),
                            ),
                          );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cancel
                  TextButton(
                    onPressed: () {
                      _countdownTimer?.cancel();
                      setState(() => _isEmergency = false);
                    },
                    child: Text(
                      'Cancel Auto-Dial',
                      style: GoogleFonts.inter(
                          fontSize: 13, color: Colors.white38),
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

  Widget _buildStandardUI() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Results', style: AppTypography.titleWhite),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkNavyGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 10), // Reduced top spacing since AppBar handles it

                const SizedBox(height: 20),

                // Status badge
                StatusBadge(status: _triageStatus)
                    .animate().fadeIn(duration: 400.ms).scale(
                        begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 8),

                Text(
                  'Analysis Complete',
                  style: AppTypography.headingWhiteMd,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Risk ring
                Center(
                  child: ProgressRing(
                    value: _riskScore / 100,
                    size: 180,
                    strokeWidth: 12,
                    label: 'Risk Score',
                  ),
                ).animate().fadeIn(delay: 400.ms).scale(
                    begin: const Offset(0.7, 0.7)),

                const SizedBox(height: 32),

                // Recommendation cards
                ..._buildRecommendations(),

                const SizedBox(height: 24),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MapScreen(showBackButton: true)),
                        ),
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.neonCyan.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.neonCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map,
                                  color: AppColors.neonCyan, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Find Hospital',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neonCyan,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.share,
                                  color: Colors.white54, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Share',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 900.ms),

                const SizedBox(height: 24),

                // Return button
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: 'Return to Dashboard',
                    icon: Icons.home,
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardScreen()),
                      (route) => false,
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRecommendations() {
    List<(String, String, IconData, Color)> recs;

    if (_riskScore > 70) {
      recs = [
        ('Proceed to ER', 'Immediate medical attention recommended',
            Icons.local_hospital, AppColors.critical),
        ('Contact Doctor', 'Schedule an urgent follow-up',
            Icons.phone, AppColors.urgent),
      ];
    } else if (_riskScore > 40) {
      recs = [
        ('Schedule Follow-up', 'Visit your doctor within 24 hours',
            Icons.calendar_today, AppColors.urgent),
        ('Monitor Symptoms', 'Keep track of any changes',
            Icons.monitor_heart, AppColors.info),
      ];
    } else {
      recs = [
        ('Self-Care', 'Rest and stay hydrated',
            Icons.self_improvement, AppColors.stable),
        ('Monitor', 'If symptoms worsen, seek medical help',
            Icons.visibility, AppColors.info),
      ];
    }

    return recs.asMap().entries.map((entry) {
      final i = entry.key;
      final r = entry.value;

      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard.subtle(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: r.$4.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(r.$3, color: r.$4, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.$1,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      r.$2,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white24, size: 20),
            ],
          ),
        ).animate().fadeIn(delay: (600 + i * 150).ms).slideX(begin: 0.05),
      );
    }).toList();
  }
}
