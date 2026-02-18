import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart';

/// Splash screen with animated gradient background, floating orbs,
/// pulsing heart icon, and typewriter app name.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Navigate after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final hue = _gradientController.value * 30; // subtle shift
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HSLColor.fromAHSL(1, 200 + hue, 0.6, 0.08).toColor(),
                  AppColors.darkBg2,
                  HSLColor.fromAHSL(1, 180 + hue, 0.5, 0.15).toColor(),
                ],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Floating orbs
            ..._buildOrbs(),

            // Center content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing heart icon
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.primaryStart.withValues(alpha: 0.4),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms)
                      .scale(begin: const Offset(0.5, 0.5)),

                  const SizedBox(height: 32),

                  // App name
                  Text(
                    'LIFELINE AI',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 800.ms)
                      .slideY(begin: 0.3),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'AI-Powered Emergency Triage',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 600.ms),
                ],
              ),
            ),

            // Loading indicator at bottom
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.neonCyan.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 1800.ms),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOrbs() {
    final rng = math.Random(42);
    return List.generate(6, (i) {
      final size = 40.0 + rng.nextDouble() * 80;
      final left = rng.nextDouble() * 400;
      final top = rng.nextDouble() * 800;
      final delay = (i * 400).ms;
      final color = i.isEven ? AppColors.neonCyan : AppColors.primaryStart;

      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.08),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn(delay: delay, duration: 2000.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 3000.ms,
              curve: Curves.easeInOut,
            ),
      );
    });
  }
}
