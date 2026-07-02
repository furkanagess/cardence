import 'package:flutter/material.dart';

/// İçindeki widget'lara yumuşak animasyonlu shimmer efekti uygular.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _curve;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = Color.lerp(
      colorScheme.surface,
      colorScheme.surfaceContainerHighest,
      isDark ? 0.42 : 0.55,
    )!;
    final highlight = Color.lerp(
      base,
      colorScheme.surface,
      isDark ? 0.22 : 0.3,
    )!;

    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final slide = (_curve.value * 2.4) - 1.2;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(slide - 0.8, -0.15),
              end: Alignment(slide + 0.8, 0.15),
              colors: [
                base,
                Color.lerp(base, highlight, 0.45)!,
                highlight,
                Color.lerp(base, highlight, 0.45)!,
                base,
              ],
              stops: const [0.0, 0.32, 0.5, 0.68, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Shimmer için tek parça placeholder (dikdörtgen veya daire).
class ShimmerPlaceholder extends StatelessWidget {
  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = Color.lerp(
      colorScheme.surface,
      colorScheme.surfaceContainerHighest,
      isDark ? 0.38 : 0.48,
    )!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: fill,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(borderRadius),
      ),
    );
  }
}
