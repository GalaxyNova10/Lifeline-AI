import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_input.dart';
import '../widgets/gradient_button.dart';
import 'register_medical_screen.dart';

class RegisterBasicScreen extends StatefulWidget {
  const RegisterBasicScreen({super.key});

  @override
  State<RegisterBasicScreen> createState() => _RegisterBasicScreenState();
}

class _RegisterBasicScreenState extends State<RegisterBasicScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  String _selectedGender = 'Male';
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.neonCyan,
              onPrimary: Colors.black,
              surface: AppColors.darkSurface,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.darkSurface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _navigateToNext() {
     if (_nameController.text.isEmpty ||
        _dobController.text.isEmpty ||
        _mobileController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _cityController.text.isEmpty) {
        
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterMedicalScreen(
          name: _nameController.text.trim(),
          dob: _dobController.text.trim(),
          mobile: _mobileController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          city: _cityController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1, // Fallback
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkNavyGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                Text(
                  "Create Account",
                  style: AppTypography.headingWhiteMd.copyWith(fontSize: 32),
                ).animate().fadeIn().slideX(),
                Text(
                  "Step 1 of 2: Basic Details",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                // Form
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GlassInput(
                        hintText: "Full Name",
                        prefixIcon: Icons.person_outline,
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                      ),
                      const SizedBox(height: 16),
                      
                      // DOB & Gender Row
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: GlassInput(
                                  hintText: "Date of Birth",
                                  prefixIcon: Icons.calendar_today_outlined,
                                  controller: _dobController,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Gender Selection
                      Container(
                        height: 50,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: ['Male', 'Female', 'Other'].map((gender) {
                            final isSelected = _selectedGender == gender;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedGender = gender),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.neonCyan.withValues(alpha: 0.2) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected ? Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5)) : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      gender,
                                      style: GoogleFonts.inter(
                                        color: isSelected ? AppColors.neonCyan : Colors.white60,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      GlassInput(
                        hintText: "Mobile Number",
                        prefixIcon: Icons.phone_android_outlined,
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      GlassInput(
                        hintText: "Email ID",
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      GlassInput(
                        hintText: "Password",
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white30,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 24),

                      // Location
                      GlassInput(
                        hintText: "City",
                        prefixIcon: Icons.location_city_outlined,
                        controller: _cityController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GlassInput(
                              hintText: "State",
                              prefixIcon: Icons.map_outlined,
                              controller: _stateController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassInput(
                              hintText: "Country",
                              prefixIcon: Icons.flag_outlined,
                              controller: _countryController,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 32),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: "Next Step",
                    icon: Icons.arrow_forward_ios,
                    onPressed: _navigateToNext,
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
