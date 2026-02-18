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
import '../widgets/gradient_button.dart';
import '../widgets/severity_slider.dart';
import '../widgets/language_pill.dart';
import '../services/api_service.dart';
import '../providers/user_provider.dart';
import 'queue_screen.dart';

/// AI Triage Screen — Step-by-step symptom assessment with
/// voice input, manual selection, pain slider, and language toggle.
class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  double _painLevel = 3;
  String _selectedLocale = 'en_US';
  bool _isListening = false;
  bool _isAnalyzing = false;
  final Set<String> _selectedSymptoms = {};
  late AnimationController _waveController;

  final _symptoms = [
    ('Headache', FontAwesomeIcons.brain),
    ('Chest Pain', FontAwesomeIcons.heartPulse),
    ('Fever', FontAwesomeIcons.temperatureHigh),
    ('Shortness of Breath', FontAwesomeIcons.lungs),
    ('Nausea', FontAwesomeIcons.faceDizzy),
    ('Dizziness', FontAwesomeIcons.spinner),
    ('Abdominal Pain', FontAwesomeIcons.bacteria),
    ('Fatigue', FontAwesomeIcons.bed),
    ('Cough', FontAwesomeIcons.virus),
    ('Back Pain', FontAwesomeIcons.personWalking),
    ('Joint Pain', FontAwesomeIcons.bone),
    ('Anxiety', FontAwesomeIcons.brain),
  ];

  final _stepLabels = [
    'Voice / Text',
    'Symptoms',
    'Severity',
    'Review',
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AI Triage', style: AppTypography.titleWhite),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkNavyGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20), // Spacing for AppBar push

              // Step indicator
              _buildStepIndicator()
                  .animate()
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    );
                  },
                  child: _buildStepContent(),
                ),
              ),

              // Navigation buttons
              _buildNavButtons(),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: List.generate(_stepLabels.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;

          return Expanded(
            child: Row(
              children: [
                // Step circle
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone
                        ? AppColors.neonCyan
                        : (isActive
                            ? AppColors.neonCyan.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.06)),
                    border: Border.all(
                      color: isActive
                          ? AppColors.neonCyan
                          : Colors.white.withValues(alpha: 0.1),
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: isDone
                        ? const Icon(Icons.check,
                            color: Colors.black, size: 14)
                        : Text(
                            '${i + 1}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.neonCyan
                                  : Colors.white30,
                            ),
                          ),
                  ),
                ),
                // Connector line
                if (i < _stepLabels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      color: isDone
                          ? AppColors.neonCyan.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVoiceStep();
      case 1:
        return _buildSymptomsStep();
      case 2:
        return _buildSeverityStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVoiceStep() {
    return SingleChildScrollView(
      key: const ValueKey('voice'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Language pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LanguagePill(
                label: '🇬🇧 ENG',
                locale: 'en_US',
                isSelected: _selectedLocale == 'en_US',
                onSelected: (l) => setState(() => _selectedLocale = l),
              ),
              const SizedBox(width: 8),
              LanguagePill(
                label: '🇮🇳 TAM',
                locale: 'ta_IN',
                isSelected: _selectedLocale == 'ta_IN',
                onSelected: (l) => setState(() => _selectedLocale = l),
              ),
              const SizedBox(width: 8),
              LanguagePill(
                label: '🇮🇳 HIN',
                locale: 'hi_IN',
                isSelected: _selectedLocale == 'hi_IN',
                onSelected: (l) => setState(() => _selectedLocale = l),
              ),
            ],
          ),

          const SizedBox(height: 36),

          // Microphone button
          GestureDetector(
            onTap: () => setState(() => _isListening = !_isListening),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isListening
                    ? const LinearGradient(
                        colors: [AppColors.neonCyan, Color(0xFF1A8A8A)])
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                border: Border.all(
                  color: _isListening
                      ? AppColors.neonCyan
                      : Colors.white.withValues(alpha: 0.15),
                  width: 2,
                ),
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? Colors.white : Colors.white60,
                size: 36,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            _isListening ? 'Listening...' : 'Tap to speak',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: _isListening ? AppColors.neonCyan : Colors.white38,
            ),
          ),

          // Voice waveform
          if (_isListening) ...[
            const SizedBox(height: 24),
            _buildWaveform(),
          ],

          const SizedBox(height: 36),

          // Divider
          Row(
            children: [
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('or describe in text',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white30)),
              ),
              Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.08))),
            ],
          ),

          const SizedBox(height: 20),

          // Text input
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: TextField(
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: AppColors.neonCyan,
                decoration: InputDecoration(
                  hintText: 'Describe your symptoms...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    final rng = math.Random();
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(20, (i) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 100 + rng.nextInt(200)),
            width: 3,
            height: 10 + rng.nextDouble() * 40,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSymptomsStep() {
    return SingleChildScrollView(
      key: const ValueKey('symptoms'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your symptoms',
            style: AppTypography.titleWhite,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose all that apply',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _symptoms.map((s) {
              final isSelected = _selectedSymptoms.contains(s.$1);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedSymptoms.remove(s.$1);
                    } else {
                      _selectedSymptoms.add(s.$1);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.neonCyan.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.neonCyan.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.neonCyan.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(
                        s.$2,
                        size: 14,
                        color:
                            isSelected ? AppColors.neonCyan : Colors.white38,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.$1,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color:
                              isSelected ? AppColors.neonCyan : Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityStep() {
    return SingleChildScrollView(
      key: const ValueKey('severity'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How severe is it?',
            style: AppTypography.titleWhite,
          ),
          const SizedBox(height: 6),
          Text(
            'Rate your current pain level',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
          ),
          const SizedBox(height: 32),

          GlassCard(
            child: SeveritySlider(
              value: _painLevel,
              onChanged: (v) => setState(() => _painLevel = v),
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'How long have you had these symptoms?',
            style: AppTypography.titleWhite.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              'Just now',
              'Few hours',
              '1-2 days',
              '3-7 days',
              '1+ week',
            ].map((d) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  d,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    if (_isAnalyzing) return _buildAnalyzing();

    return SingleChildScrollView(
      key: const ValueKey('review'),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Submit', style: AppTypography.titleWhite),
          const SizedBox(height: 20),

          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Symptoms',
                    style: AppTypography.bodySmall.copyWith(color: Colors.white38)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedSymptoms.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.neonCyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(s,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.neonCyan)),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                Divider(color: Colors.white.withValues(alpha: 0.08)),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pain Level',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white54)),
                    Text('${_painLevel.toInt()}/10',
                        style: AppTypography.dataWhite),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Language',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.white54)),
                    Text(
                      _selectedLocale == 'en_US'
                          ? 'English'
                          : (_selectedLocale == 'ta_IN' ? 'Tamil' : 'Hindi'),
                      style: AppTypography.dataWhite,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzing() {
    return Center(
      key: const ValueKey('analyzing'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
            ),
          ).animate(onPlay: (c) => c.repeat())
              .rotate(duration: 2000.ms),
          const SizedBox(height: 24),
          Text(
            'Analyzing Symptoms...',
            style: AppTypography.titleWhite,
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            'AI is processing your assessment',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white38),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _currentStep--),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Back',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: GradientButton(
              label: _currentStep == 3 ? 'Submit' : 'Continue',
              icon: _currentStep == 3
                  ? Icons.send
                  : Icons.arrow_forward,
              onPressed: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  // Submit — call triage API
                  setState(() => _isAnalyzing = true);
                  _submitTriage();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitTriage() async {
    final provider = context.read<UserProvider>();
    final result = await ApiService.triageProcess(
      age: provider.age,
      heartRate: provider.lastBpm ?? 72,
      symptoms: _selectedSymptoms.toList(),
    );

    if (!mounted) return;

    final triage = result['triage'] as Map<String, dynamic>? ?? {};
    final score = triage['score'] as int? ?? (_painLevel * 10).toInt();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QueueScreen(
          selectedSymptoms: _selectedSymptoms.toList(),
          painLevel: _painLevel.toInt(),
          triageScore: score,
          triageRisk: triage['risk'] as String? ?? 'MODERATE',
          triageResult: result,
        ),
      ),
    );
  }
}
