import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_input.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'dashboard_screen.dart';
import 'register_basic_screen.dart';

/// Login screen with gradient mesh background, glassmorphic auth card,
/// social login ghost buttons, and staggered entrance animations.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Enter a valid email');
      return;
    }
    if (password.length < 4) {
      setState(() => _passwordError = 'Password too short');
      return;
    }

    setState(() => _isLoading = true);

    // Real API call with mock fallback
    final result = await ApiService.login(email: email, password: password);
    final token = result['token'] ?? '';
    final name = result['name'] ?? email.split('@').first;

    if (mounted) {
      final provider = context.read<UserProvider>();
      provider.setProfile(token: token, name: name, role: 'patient');
      await provider.persistToken();

      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) {
            return FadeTransition(opacity: anim, child: child);
          },
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.darkNavyGradient,
        ),
        child: Stack(
          children: [
            // Gradient mesh orbs
            _buildMeshOrbs(size),

            // Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryStart
                                  .withValues(alpha: 0.35),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite,
                            color: Colors.white, size: 32),
                      ).animate().fadeIn(duration: 600.ms).scale(
                          begin: const Offset(0.6, 0.6)),

                      const SizedBox(height: 24),

                      // Welcome text
                      Text(
                        'Welcome Back',
                        style: AppTypography.headingWhiteMd,
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms),

                      const SizedBox(height: 6),

                      Text(
                        'Sign in to Lifeline AI',
                        style: AppTypography.bodyWhiteDim,
                      ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

                      const SizedBox(height: 40),

                      // Auth card
                      GlassCard.elevated(
                        child: Column(
                          children: [
                            // Email
                            GlassInput(
                              hintText: 'Email address',
                              prefixIcon: Icons.email_outlined,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              errorText: _emailError,
                            ),

                            const SizedBox(height: 16),

                            // Password
                            GlassInput(
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              errorText: _passwordError,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white30,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Forgot password
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.neonCyan,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Login button
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                label: 'Sign In',
                                icon: Icons.arrow_forward,
                                isLoading: _isLoading,
                                onPressed: _isLoading ? null : _handleLogin,
                              ),
                            ),



                            const SizedBox(height: 16),
                            
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const RegisterBasicScreen()),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  "Create New Account",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                      const SizedBox(height: 24),

                      // Terms
                      Text(
                        'By continuing, you agree to our Terms & Privacy Policy',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white24,
                        ),
                      ).animate().fadeIn(delay: 800.ms),

                      const SizedBox(height: 40),
                    ], // GlassCard List
                  ),   // GlassCard Column
                ),     // GlassCard
              ],       // Main List
            ),         // Main Column
          ),           // ScrollView
        ),             // Center
      ),               // SafeArea
    ],                 // Stack List
  ),                   // Stack
),                     // Container
    );
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
                  AppColors.primaryStart.withValues(alpha: 0.08),
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
                  AppColors.neonCyan.withValues(alpha: 0.06),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(icon, color: Colors.white60, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
