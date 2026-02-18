import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// Skeleton loading shimmer with gradient sweep animation.
/// Provides card, circle, and text line shape variants.
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 120,
    this.borderRadius,
  });

  /// Circle shape (for avatars)
  const ShimmerLoader.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null;

  /// Text line shape
  const ShimmerLoader.text({
    super.key,
    this.width = 200,
  })  : height = 14,
        borderRadius = null;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCircle = widget.width == widget.height && widget.borderRadius == null && widget.height != 14;
    final radius = widget.borderRadius ??
        (isCircle
            ? BorderRadius.circular(999)
            : (widget.height == 14
                ? BorderRadius.circular(7)
                : AppSpacing.borderRadiusMd));

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-1.0 + 2.0 * _controller.value + 1.0, 0),
              colors: [
                Colors.white.withValues(alpha: 0.04),
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.04),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Group of shimmer lines to simulate text loading
class ShimmerTextBlock extends StatelessWidget {
  final int lines;
  final double spacing;

  const ShimmerTextBlock({
    super.key,
    this.lines = 3,
    this.spacing = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) {
        final isLast = i == lines - 1;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
          child: ShimmerLoader.text(
            width: isLast ? 120 : double.infinity,
          ),
        );
      }),
    );
  }
}
