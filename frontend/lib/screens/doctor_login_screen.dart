import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'doctor_dashboard_screen.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final result = await ApiService.login(email: email, password: _passwordController.text);
    final token = result['token'] ?? '';
    final name = result['name'] ?? 'Dr. ${email.split('@').first}';

    if (mounted) {
      final provider = context.read<UserProvider>();
      provider.setProfile(token: token, name: name, role: 'doctor');
      await provider.persistToken();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DoctorDashboardScreen()),
        (route) => false,
      );
    }
  }

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

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BackButton(color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neonRed.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const FaIcon(
                        FontAwesomeIcons.userDoctor,
                        size: 40,
                        color: AppColors.neonRed,
                      ),
                    ).animate().fadeIn().scale(),
                    
                    const SizedBox(height: 24),
                    
                    Text(
                      "Doctor Portal",
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(),
                    
                    Text(
                      "Secure access for medical professionals",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white54,
                      ),
                    ).animate().fadeIn(delay: 300.ms).slideX(),

                    const SizedBox(height: 48),

                    // Form
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Medical ID / Email",
                              labelStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.badge, color: AppColors.neonRed),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.neonRed),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Password",
                              labelStyle: const TextStyle(color: Colors.white54),
                              prefixIcon: const Icon(Icons.lock, color: AppColors.neonRed),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: AppColors.neonRed),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: InkWell(
                            onTap: _isLoading ? null : _handleLogin,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.neonRed, AppColors.primaryEnd],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonRed.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Access Dashboard",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
