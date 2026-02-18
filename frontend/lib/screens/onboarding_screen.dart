import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';

/// Onboarding — 3 page carousel with smooth indicator,
/// animated illustrations, and skip/next flow.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPage(
      icon: Icons.health_and_safety,
      title: 'AI-Powered Triage',
      subtitle:
          'Describe your symptoms by voice or text in English, Tamil, or Hindi. Our AI instantly assesses severity.',
      color: AppColors.neonCyan,
    ),
    _OnboardingPage(
      icon: Icons.local_hospital,
      title: 'Find Nearest ER',
      subtitle:
          'Real-time hospital wait times and navigation to the closest emergency room with the shortest wait.',
      color: AppColors.primaryStart,
    ),
    _OnboardingPage(
      icon: Icons.badge,
      title: 'Digital Health ID',
      subtitle:
          'Your medical history, allergies, and records in one secure digital passport. Share via QR instantly.',
      color: AppColors.stable,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkNavyGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.inter(
                        fontSize: 14, color: Colors.white38),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final page = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon circle
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  page.color.withValues(alpha: 0.2),
                                  page.color.withValues(alpha: 0.03),
                                ],
                              ),
                              border: Border.all(
                                color: page.color.withValues(alpha: 0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: page.color.withValues(alpha: 0.12),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: Icon(
                              page.icon,
                              color: page.color,
                              size: 52,
                            ),
                          ),

                          const SizedBox(height: 48),

                          Text(
                            page.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              height: 1.6,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Page indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.neonCyan,
                  dotColor: Colors.white.withValues(alpha: 0.15),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                ),
              ),

              const SizedBox(height: 40),

              // Bottom button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    icon: _currentPage == _pages.length - 1
                        ? Icons.arrow_forward
                        : Icons.arrow_forward_ios,
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                        );
                      } else {
                        _goToLogin();
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
