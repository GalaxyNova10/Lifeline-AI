import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Frosted glass text field with animated focus ring glow,
/// error shake animation, and prefix/suffix icon support.
class GlassInput extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int maxLines;

  const GlassInput({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput>
    with SingleTickerProviderStateMixin {
  bool _isFocused = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(covariant GlassInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != null && oldWidget.errorText == null) {
      _shakeController.forward().then((_) => _shakeController.reverse());
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null;
    final glowColor =
        hasError ? AppColors.critical : (_isFocused ? AppColors.neonCyan : Colors.transparent);

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value *
                ((_shakeController.value * 10).toInt().isEven ? 1 : -1),
            0,
          ),
          child: child,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            if (_isFocused || hasError)
              BoxShadow(
                color: glowColor.withValues(alpha: 0.2),
                blurRadius: 16,
                spreadRadius: 0,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Focus(
              onFocusChange: (focused) => setState(() => _isFocused = focused),
              child: TextField(
                controller: widget.controller,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                onChanged: widget.onChanged,
                onTap: widget.onTap,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: AppColors.neonCyan,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  labelText: widget.labelText,
                  errorText: widget.errorText,
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(widget.prefixIcon,
                          color: _isFocused
                              ? AppColors.neonCyan
                              : Colors.white38,
                          size: 20)
                      : null,
                  suffixIcon: widget.suffixIcon,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: hasError ? AppColors.critical : AppColors.neonCyan,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.critical),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
