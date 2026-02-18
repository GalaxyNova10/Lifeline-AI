import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/glass_card.dart';
import '../widgets/glass_input.dart';
import '../widgets/gradient_button.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'dashboard_screen.dart';

class RegisterMedicalScreen extends StatefulWidget {
  final String name;
  final String dob;
  final String mobile;
  final String email;
  final String password;
  final String city;

  const RegisterMedicalScreen({
    super.key,
    this.name = '',
    this.dob = '',
    this.mobile = '',
    this.email = '',
    this.password = '',
    this.city = '',
  });

  @override
  State<RegisterMedicalScreen> createState() => _RegisterMedicalScreenState();
}

class _RegisterMedicalScreenState extends State<RegisterMedicalScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _surgeryNameController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String _bloodGroup = 'A+';
  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
  
  final Set<String> _selectedDiseases = {};
  final List<String> _diseases = ['Diabetes', 'Hypertension', 'Asthma', 'Thyroid', 'Heart Disease', 'None'];

  bool _smokes = false;
  bool _drinks = false;
  bool _hadSurgery = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _surgeryNameController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _finishRegistration() async {
    if (_isLoading) return; // prevent double-tap
    setState(() => _isLoading = true);

    try {
      // Call API with combined basic + medical data
      final result = await ApiService.register(
        name: widget.name.isNotEmpty ? widget.name : 'Patient',
        age: _calculateAge(widget.dob),
        bloodType: _bloodGroup,
        allergies: _allergiesController.text,
        conditions: _selectedDiseases.join(', '),
        contact: widget.mobile,
      );

      if (!mounted) return;

      final token = result['token'] ?? '';
      final provider = context.read<UserProvider>();
      provider.setProfile(
        token: token,
        name: widget.name.isNotEmpty ? widget.name : 'Patient',
        role: 'patient',
        age: _calculateAge(widget.dob),
        bloodType: _bloodGroup,
        conditions: _selectedDiseases.join(', '),
        allergies: _allergiesController.text,
      );
      await provider.persistToken();

      // Show success dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 64),
                const SizedBox(height: 16),
                Text("Registration Complete!", style: AppTypography.headingWhiteMd, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text("Your medical profile has been created.", style: GoogleFonts.inter(color: Colors.white70), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: "Go to Dashboard",
                    icon: Icons.dashboard,
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        (route) => false,
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Registration error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _calculateAge(String dob) {
    try {
      final parts = dob.split(RegExp(r'[/\-]'));
      if (parts.length == 3) {
        final year = int.parse(parts.last.length == 4 ? parts.last : parts.first);
        return DateTime.now().year - year;
      }
    } catch (_) {}
    return 30;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg1,
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
                  "Medical Profile",
                  style: AppTypography.headingWhiteMd.copyWith(fontSize: 32),
                ).animate().fadeIn().slideX(),
                Text(
                  "Step 2 of 2: Clinical Data",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Blood Group Dropdown
                      Text("Blood Group", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _bloodGroup,
                            dropdownColor: AppColors.darkSurface,
                            isExpanded: true,
                            style: GoogleFonts.inter(color: Colors.white),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            items: _bloodGroups.map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                            onChanged: (v) => setState(() => _bloodGroup = v!),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Biometrics
                      Row(
                        children: [
                          Expanded(
                            child: GlassInput(
                              hintText: "Height (cm)",
                              prefixIcon: Icons.height,
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassInput(
                              hintText: "Weight (kg)",
                              prefixIcon: Icons.monitor_weight_outlined,
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Chronic Diseases
                      Text("Chronic Diseases", style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _diseases.map((d) {
                          final isStart = _selectedDiseases.contains(d);
                          return FilterChip(
                            label: Text(d),
                            selected: isStart,
                            onSelected: (v) => setState(() {
                              if(v) _selectedDiseases.add(d); else _selectedDiseases.remove(d);
                            }),
                            backgroundColor: Colors.white.withValues(alpha: 0.05),
                            selectedColor: AppColors.neonCyan.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.neonCyan,
                            labelStyle: GoogleFonts.inter(color: isStart ? AppColors.neonCyan : Colors.white70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isStart ? AppColors.neonCyan : Colors.white10),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 16),
                      GlassInput(
                        hintText: "Major Allergies (e.g. Peanuts)",
                        prefixIcon: Icons.warning_amber_rounded,
                        controller: _allergiesController,
                      ),
                      
                      const SizedBox(height: 16),
                      GlassInput(
                        hintText: "Current Medications",
                        prefixIcon: Icons.medication_outlined,
                        controller: _medicationsController,
                      ),

                      const SizedBox(height: 24),
                      Divider(color: Colors.white.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      
                      // Lifestyle
                      SwitchListTile(
                        title: Text("Do you smoke?", style: GoogleFonts.inter(color: Colors.white)),
                        value: _smokes,
                        activeColor: AppColors.neonRed,
                        onChanged: (v) => setState(() => _smokes = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: Text("Do you drink alcohol?", style: GoogleFonts.inter(color: Colors.white)),
                        value: _drinks,
                        activeColor: AppColors.neonYellow,
                        onChanged: (v) => setState(() => _drinks = v),
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),
                
                // Emergency Contact Box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.neonRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neonRed.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.contact_phone, color: AppColors.neonRed),
                          const SizedBox(width: 8),
                          Text("Emergency Contact", style: GoogleFonts.outfit(color: AppColors.neonRed, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GlassInput(
                        hintText: "Contact Name",
                        prefixIcon: Icons.person,
                        controller: _emergencyNameController,
                      ),
                      const SizedBox(height: 12),
                      GlassInput(
                        hintText: "Contact Number",
                        prefixIcon: Icons.phone,
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: GradientButton(
                    label: "Complete Registration",
                    icon: Icons.check_circle_outline,
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _finishRegistration,
                  ),
                ).animate().fadeIn(delay: 800.ms),
                
                 const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
