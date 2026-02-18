import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';

/// QR Lock Screen — PIN-protected health passport viewer
/// with animated QR code and biometric option.
class QrLockScreen extends StatefulWidget {
  const QrLockScreen({super.key});

  @override
  State<QrLockScreen> createState() => _QrLockScreenState();
}

class _QrLockScreenState extends State<QrLockScreen> {
  String _pin = '';
  bool _hasError = false;
  final _correctPin = '1234';

  void _addDigit(String d) {
    if (_pin.length >= 4) return;
    setState(() {
      _pin += d;
      _hasError = false;
    });

    if (_pin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_pin == _correctPin) {
          _showQrOverlay();
        } else {
          setState(() {
            _hasError = true;
            _pin = '';
          });
        }
      });
    }
  }

  void _removeLast() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _hasError = false;
    });
  }

  void _showQrOverlay() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.darkSurface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.neonCyan.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Share Health Data',
                      style: AppTypography.titleWhite),
                  const SizedBox(height: 8),
                  Text(
                    'Scan this QR code',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.white38),
                  ),
                  const SizedBox(height: 24),

                  // QR placeholder
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(Icons.qr_code_2,
                          color: AppColors.darkBg1, size: 160),
                    ),
                  ).animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8)),

                  const SizedBox(height: 20),

                  Text(
                    'LF-2024-002847',
                    style: GoogleFonts.firaCode(
                      fontSize: 14,
                      color: AppColors.neonCyan,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    'Expires in 5:00',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.white30),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      label: 'Close',
                      icon: Icons.close,
                      onPressed: () => Navigator.pop(ctx),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkNavyGradient),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white60, size: 20),
                    ),
                    const Spacer(),
                    Text('Health QR',
                        style: AppTypography.titleWhite),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const Spacer(),

              // Lock icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _hasError ? Icons.lock_outline : Icons.lock,
                  color: _hasError
                      ? AppColors.critical
                      : AppColors.neonCyan,
                  size: 36,
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              Text(
                _hasError ? 'Wrong PIN. Try again.' : 'Enter PIN to unlock',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _hasError ? AppColors.critical : Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Your health data is protected',
                style: GoogleFonts.inter(
                    fontSize: 13, color: Colors.white38),
              ),

              const SizedBox(height: 36),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final isFilled = i < _pin.length;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isFilled
                          ? (_hasError ? AppColors.critical : AppColors.neonCyan)
                          : Colors.transparent,
                      border: Border.all(
                        color: _hasError
                            ? AppColors.critical
                            : (isFilled
                                ? AppColors.neonCyan
                                : Colors.white.withValues(alpha: 0.2)),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 48),

              // Number pad
              _buildNumPad(),

              const SizedBox(height: 24),

              // Biometric button
              GestureDetector(
                onTap: () => _showQrOverlay(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.fingerprint,
                        color: AppColors.neonCyan, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Use Biometric',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumPad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((key) {
                if (key.isEmpty) return const SizedBox(width: 72);
                return _NumKey(
                  label: key,
                  onTap: () {
                    if (key == '⌫') {
                      _removeLast();
                    } else {
                      _addDigit(key);
                    }
                  },
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NumKey({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Center(
          child: label == '⌫'
              ? const Icon(Icons.backspace_outlined,
                  color: Colors.white60, size: 20)
              : Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
