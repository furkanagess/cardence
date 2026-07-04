import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/splash_theme.dart';

/// Tek logonun sol ve sağ yarısının birleşip Cardence zincir logosunu oluşturduğu animasyon.
class CardenceLogoMergeAnimation extends StatefulWidget {
  const CardenceLogoMergeAnimation({
    super.key,
    this.size = 220,
    this.repeat = true,
    this.duration = defaultDuration,
    this.pauseBetweenCycles = const Duration(milliseconds: 900),
    this.logoAssetPath,
  });

  static const Duration defaultDuration = Duration(milliseconds: 1900);

  /// Splash ekranı en az bir animasyon döngüsü tamamlanana kadar görünür.
  static Duration get minSplashVisibleDuration => defaultDuration;

  /// Splash ve büyük logo alanları için önerilen boyut.
  static const double splashSize = 300;

  final double size;
  final bool repeat;
  final Duration duration;
  final Duration pauseBetweenCycles;
  final String? logoAssetPath;

  @override
  State<CardenceLogoMergeAnimation> createState() =>
      _CardenceLogoMergeAnimationState();
}

class _CardenceLogoMergeAnimationState extends State<CardenceLogoMergeAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _merge;
  late final Animation<double> _shine;
  late final Animation<double> _reveal;
  late final Animation<double> _settle;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _merge = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.72, curve: Curves.easeOutCubic),
    );
    _shine = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.58, 0.9, curve: Curves.easeOut),
    );
    _reveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.72, 0.94, curve: Curves.easeOutCubic),
    );
    _settle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.82, 1, curve: Curves.easeInOut),
    );

    if (widget.repeat) {
      _controller.addStatusListener(_onAnimationStatus);
    }
    _controller.forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !widget.repeat || !mounted) {
      return;
    }
    Future<void>.delayed(widget.pauseBetweenCycles, () {
      if (!mounted) return;
      _controller.forward(from: 0);
    });
  }

  @override
  void didUpdateWidget(CardenceLogoMergeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.repeat != widget.repeat) {
      _controller.removeStatusListener(_onAnimationStatus);
      if (widget.repeat) {
        _controller.addStatusListener(_onAnimationStatus);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  String _resolveLogoAsset(BuildContext context) {
    if (widget.logoAssetPath != null) return widget.logoAssetPath!;
    final brightness = Theme.of(context).brightness;
    return SplashTheme.logoAsset(brightness);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final logoAsset = _resolveLogoAsset(context);
    final logoSize = widget.size * 0.78;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final mergeT = _merge.value;
          final shineT = _shine.value;
          final revealT = _reveal.value;
          final settleT = _settle.value;
          final gap = logoSize * 0.38 * (1 - mergeT);
          final halvesOpacity = (1 - revealT * 1.2).clamp(0.0, 1.0);
          final fullOpacity = revealT.clamp(0.0, 1.0);
          final pulse = 1 + math.sin(settleT * math.pi) * 0.02;
          final glowOpacity = (shineT * (1 - shineT * 0.3)).clamp(0.0, 1.0);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final shineHighlight =
              isDark ? AppColors.textOnPrimary : AppColors.surfaceLight;

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (glowOpacity > 0.01)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _MergeGlowPainter(
                    progress: glowOpacity,
                    color: colorScheme.primary,
                  ),
                ),
              if (halvesOpacity > 0.01)
                Opacity(
                  opacity: halvesOpacity,
                  child: _SplitLogoHalves(
                    assetPath: logoAsset,
                    logoSize: logoSize,
                    gap: gap,
                  ),
                ),
              if (fullOpacity > 0.01)
                Opacity(
                  opacity: fullOpacity,
                  child: Transform.scale(
                    scale: (0.96 + revealT * 0.04) * pulse,
                    child: Image.asset(
                      logoAsset,
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.credit_card_rounded,
                        size: logoSize * 0.72,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              if (shineT > 0.02)
                IgnorePointer(
                  child: CustomPaint(
                    size: Size(logoSize, logoSize),
                    painter: _MergeShinePainter(
                      progress: shineT,
                      highlightColor: shineHighlight,
                      accentColor: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Tek görselin sol ve sağ yarısını ortada birleştirir.
class _SplitLogoHalves extends StatelessWidget {
  const _SplitLogoHalves({
    required this.assetPath,
    required this.logoSize,
    required this.gap,
  });

  final String assetPath;
  final double logoSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final halfWidth = logoSize / 2;

    return SizedBox(
      width: logoSize,
      height: logoSize,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            left: -(gap / 2),
            top: 0,
            width: halfWidth,
            height: logoSize,
            child: ClipRect(
              child: OverflowBox(
                maxWidth: logoSize,
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  assetPath,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Positioned(
            left: halfWidth + (gap / 2),
            top: 0,
            width: halfWidth,
            height: logoSize,
            child: ClipRect(
              child: OverflowBox(
                maxWidth: logoSize,
                alignment: Alignment.centerRight,
                child: Image.asset(
                  assetPath,
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MergeGlowPainter extends CustomPainter {
  _MergeGlowPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * (0.16 + progress * 0.4);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.5 * progress),
          color.withValues(alpha: 0.16 * progress),
          color.withValues(alpha: 0),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _MergeGlowPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _MergeShinePainter extends CustomPainter {
  _MergeShinePainter({
    required this.progress,
    required this.highlightColor,
    required this.accentColor,
  });

  final double progress;
  final Color highlightColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final fade = (1 - progress * 0.85).clamp(0.0, 1.0);

    final burstPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          highlightColor.withValues(alpha: 0.8 * fade),
          accentColor.withValues(alpha: 0.32 * fade),
          accentColor.withValues(alpha: 0),
        ],
        stops: const [0, 0.35, 1],
      ).createShader(
        Rect.fromCircle(
          center: center,
          radius: size.width * (0.1 + progress * 0.3),
        ),
      );
    canvas.drawCircle(
      center,
      size.width * (0.1 + progress * 0.3),
      burstPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MergeShinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.accentColor != accentColor;
  }
}
