import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AnimatedSuccessCheck extends StatefulWidget {
  const AnimatedSuccessCheck({
    super.key,
    this.size = 72,
  });

  final double size;

  @override
  State<AnimatedSuccessCheck> createState() => _AnimatedSuccessCheckState();
}

class _AnimatedSuccessCheckState extends State<AnimatedSuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconSize = widget.size * 0.42;

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: isDark ? 0.22 : 0.12),
            shape: BoxShape.circle,
          ),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Icon(
              Icons.check_rounded,
              size: iconSize,
              color: AppColors.success,
            ),
          ),
        ),
      ),
    );
  }
}
