import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/card_visual_effect.dart';
import '../../theme/app_colors.dart';

/// Kart yüzeyine animasyonlu görsel efekt uygular.
class CardEffectOverlay extends StatefulWidget {
  const CardEffectOverlay({
    super.key,
    required this.effect,
    required this.child,
    this.accentColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
  });

  final CardVisualEffect effect;
  final Widget child;
  final Color? accentColor;
  final BorderRadius borderRadius;

  @override
  State<CardEffectOverlay> createState() => _CardEffectOverlayState();
}

class _CardEffectOverlayState extends State<CardEffectOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    if (widget.effect != CardVisualEffect.none) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(CardEffectOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.effect == CardVisualEffect.none) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _glowColor => widget.accentColor ?? AppColors.primary;

  @override
  Widget build(BuildContext context) {
    if (widget.effect == CardVisualEffect.none) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.passthrough,
          children: [
            if (widget.effect == CardVisualEffect.neon ||
                widget.effect == CardVisualEffect.glow ||
                widget.effect == CardVisualEffect.pulse ||
                widget.effect == CardVisualEffect.fire)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: widget.borderRadius,
                    boxShadow: _outerShadow(t),
                  ),
                ),
              ),
            ClipRRect(
              borderRadius: widget.borderRadius,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  child!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _CardEffectPainter(
                          effect: widget.effect,
                          progress: t,
                          accentColor: _glowColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      child: widget.child,
    );
  }

  List<BoxShadow> _outerShadow(double t) {
    switch (widget.effect) {
      case CardVisualEffect.neon:
        final pulse = 0.55 + math.sin(t * math.pi * 2) * 0.25;
        return [
          BoxShadow(
            color: _glowColor.withValues(alpha: 0.55 * pulse),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: _glowColor.withValues(alpha: 0.25 * pulse),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ];
      case CardVisualEffect.glow:
        return [
          BoxShadow(
            color: _glowColor.withValues(alpha: 0.35),
            blurRadius: 22,
            spreadRadius: 1,
          ),
        ];
      case CardVisualEffect.pulse:
        final pulse = 0.4 + math.sin(t * math.pi * 2) * 0.35;
        return [
          BoxShadow(
            color: _glowColor.withValues(alpha: pulse),
            blurRadius: 14 + pulse * 8,
            spreadRadius: pulse * 2,
          ),
        ];
      case CardVisualEffect.fire:
        final pulse = 0.4 + math.sin(t * math.pi * 2) * 0.25;
        return [
          BoxShadow(
            color: const Color(0xFFFF5722).withValues(alpha: pulse * 0.85),
            blurRadius: 24,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: pulse * 0.45),
            blurRadius: 36,
            spreadRadius: 2,
          ),
        ];
      default:
        return const [];
    }
  }
}

class _CardEffectPainter extends CustomPainter {
  _CardEffectPainter({
    required this.effect,
    required this.progress,
    required this.accentColor,
  });

  final CardVisualEffect effect;
  final double progress;
  final Color accentColor;

  static const _particles = [
    Offset(0.12, 0.18),
    Offset(0.82, 0.14),
    Offset(0.68, 0.72),
    Offset(0.24, 0.78),
    Offset(0.48, 0.42),
    Offset(0.9, 0.52),
    Offset(0.08, 0.55),
    Offset(0.58, 0.22),
    Offset(0.34, 0.62),
    Offset(0.76, 0.38),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    switch (effect) {
      case CardVisualEffect.none:
        return;
      case CardVisualEffect.stars:
        _paintStars(canvas, size);
      case CardVisualEffect.sparkle:
        _paintSparkle(canvas, size);
      case CardVisualEffect.shimmer:
        _paintShimmer(canvas, size);
      case CardVisualEffect.neon:
        _paintNeonBorder(canvas, size);
      case CardVisualEffect.glow:
        _paintSoftSheen(canvas, size, 0.12);
      case CardVisualEffect.aurora:
        _paintAurora(canvas, size);
      case CardVisualEffect.pulse:
        _paintSoftSheen(canvas, size, 0.08 + math.sin(progress * math.pi * 2) * 0.06);
      case CardVisualEffect.holographic:
        _paintHolographic(canvas, size);
      case CardVisualEffect.rain:
        _paintRain(canvas, size);
      case CardVisualEffect.snow:
        _paintSnow(canvas, size);
      case CardVisualEffect.fire:
        _paintFire(canvas, size);
      case CardVisualEffect.confetti:
        _paintConfetti(canvas, size);
      case CardVisualEffect.cosmic:
        _paintCosmic(canvas, size);
      case CardVisualEffect.ripple:
        _paintRipple(canvas, size);
      case CardVisualEffect.diamond:
        _paintDiamond(canvas, size);
      case CardVisualEffect.sunset:
        _paintSunset(canvas, size);
      case CardVisualEffect.frost:
        _paintFrost(canvas, size);
      case CardVisualEffect.matrix:
        _paintMatrix(canvas, size);
    }
  }

  void _paintStars(Canvas canvas, Size size) {
    for (var i = 0; i < _particles.length; i++) {
      final base = _particles[i];
      final phase = (progress + i * 0.11) % 1.0;
      final alpha = (math.sin(phase * math.pi * 2) * 0.5 + 0.5) * 0.85;
      final center = Offset(base.dx * size.width, base.dy * size.height);
      _drawStar(canvas, center, 4 + (i.isEven ? 1.0 : 0.0), accentColor.withValues(alpha: alpha));
    }
  }

  void _paintSparkle(Canvas canvas, Size size) {
    for (var i = 0; i < _particles.length; i++) {
      final base = _particles[i];
      final phase = (progress * 1.4 + i * 0.08) % 1.0;
      final alpha = math.pow(math.sin(phase * math.pi), 2).toDouble() * 0.95;
      final center = Offset(base.dx * size.width, base.dy * size.height);
      _drawSparkleCross(canvas, center, 5, accentColor.withValues(alpha: alpha));
    }
  }

  void _paintShimmer(Canvas canvas, Size size) {
    final sweep = (progress * 2 - 0.5) * size.width;
    final rect = Rect.fromLTWH(sweep - size.width * 0.35, 0, size.width * 0.35, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.surfaceLight.withValues(alpha: 0.05),
          AppColors.surfaceLight.withValues(alpha: 0.35),
          AppColors.surfaceLight.withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0, 0.35, 0.5, 0.65, 1],
      ).createShader(rect);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _paintNeonBorder(Canvas canvas, Size size) {
    final pulse = 0.55 + math.sin(progress * math.pi * 2) * 0.25;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(17),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = accentColor.withValues(alpha: 0.75 * pulse);
    canvas.drawRRect(rrect, paint);
  }

  void _paintSoftSheen(Canvas canvas, Size size, double alpha) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor.withValues(alpha: alpha),
          Colors.transparent,
          accentColor.withValues(alpha: alpha * 0.6),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintAurora(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final shift = progress * math.pi * 2;
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment(math.cos(shift), -1),
        end: Alignment(-math.cos(shift), 1),
        colors: [
          accentColor.withValues(alpha: 0.18),
          AppColors.primary.withValues(alpha: 0.12),
          AppColors.primaryLight.withValues(alpha: 0.16),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintHolographic(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: progress * math.pi * 2,
        colors: const [
          Color(0x22FF6B9D),
          Color(0x224FC3F7),
          Color(0x22A78BFA),
          Color(0x22FBBF24),
          Color(0x22FF6B9D),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    _paintShimmer(canvas, size);
  }

  void _paintRain(Canvas canvas, Size size) {
    const dropCount = 52;
    const windX = -4.5;

    for (var i = 0; i < dropCount; i++) {
      final layer = i % 3;
      final speed = 1.15 + layer * 0.45;
      final length = 10.0 + layer * 6.5;
      final stroke = 0.7 + layer * 0.35;

      final seedX = (i * 53.7 + 11) % size.width;
      final travel = progress * size.height * speed * 2.1;
      final y = (i * 19.3 + travel) % (size.height + length) - length * 0.2;
      final drift = progress * size.width * (0.04 + layer * 0.02);
      final x = (seedX + drift) % size.width;

      final head = Offset(x, y);
      final tail = head + Offset(windX * (0.85 + layer * 0.08), length);

      final alpha = 0.22 + layer * 0.14;
      final rainPaint = Paint()
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF9EC5E8).withValues(alpha: alpha * 0.35),
            const Color(0xFFDCEEFF).withValues(alpha: alpha),
            const Color(0xFFB8D4F0).withValues(alpha: alpha * 0.55),
          ],
        ).createShader(Rect.fromPoints(head, tail));

      canvas.drawLine(head, tail, rainPaint);
    }

    final mistPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF5B8CB8).withValues(alpha: 0.06),
          const Color(0xFF4A7AA8).withValues(alpha: 0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), mistPaint);
  }

  void _paintSnow(Canvas canvas, Size size) {
    const flakeCount = 42;

    for (var i = 0; i < flakeCount; i++) {
      final layer = i % 3;
      final speed = 0.28 + layer * 0.16;
      final radius = 0.9 + layer * 0.75 + (i % 3) * 0.35;

      final seedX = (i * 41.9 + 7) % size.width;
      final travel = progress * size.height * speed;
      final y = (i * 23.1 + travel) % (size.height + radius * 2);
      final sway = math.sin(progress * math.pi * 2 + i * 0.85) * (3.5 + layer * 2.5);
      final x = (seedX + sway + progress * size.width * 0.025) % size.width;

      final center = Offset(x, y);
      final alpha = 0.38 + layer * 0.18;
      final color = Color.lerp(
        const Color(0xFFF8FBFF),
        const Color(0xFFE3EEF8),
        layer / 2,
      )!
          .withValues(alpha: alpha);

      if (radius > 1.8 && i.isEven) {
        _drawSnowflake(canvas, center, radius * 1.6, color);
      } else {
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..color = color
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6),
        );
      }
    }

    final hazePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.surfaceLight.withValues(alpha: 0.04),
          AppColors.surfaceLight.withValues(alpha: 0.08),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), hazePaint);
  }

  void _paintFire(Canvas canvas, Size size) {
    const borderRadius = 17.0;
    const borderInset = 0.5;
    final rect = Rect.fromLTWH(
      borderInset,
      borderInset,
      size.width - borderInset * 2,
      size.height - borderInset * 2,
    );
    final rrect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(borderRadius),
    );
    final center = rect.center;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.92,
          colors: [
            Colors.transparent,
            Colors.transparent,
            const Color(0x33FF5722),
            const Color(0x55FF9800),
          ],
          stops: const [0, 0.58, 0.84, 1],
        ).createShader(rect),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final perimeter = metric.length;
    final spacing = size.width * 0.065;
    final flameCount = (perimeter / spacing).round().clamp(20, 34);

    for (var i = 0; i < flameCount; i++) {
      final offset =
          (i / flameCount * perimeter + progress * perimeter * 0.018) %
              perimeter;
      final tangent = metric.getTangentForOffset(offset);
      if (tangent == null) continue;

      final base = tangent.position;
      final inward = _inwardNormal(tangent.vector, center, base);
      final perp = _normalizeOffset(tangent.vector);
      final flicker =
          math.sin(progress * math.pi * 6 + i * 1.35) * 0.14 +
          math.sin(progress * math.pi * 3.5 + i * 2.1) * 0.08;

      final height = size.height *
          (0.2 + (i.isEven ? 0.05 : 0.0) + flicker.abs() * 0.1);
      final width = size.width *
          (0.05 + (i % 3) * 0.011 + flicker.abs() * 0.018);

      _drawFlameTongueOnBorder(
        canvas: canvas,
        base: base,
        inward: inward,
        perp: perp,
        width: width,
        height: height,
        wobble: flicker,
      );
    }

    for (var i = 0; i < 16; i++) {
      final phase = (progress * 1.6 + i * 0.11) % 1.0;
      final offset = (i * 47.3 + phase * perimeter * 0.18) % perimeter;
      final tangent = metric.getTangentForOffset(offset);
      if (tangent == null) continue;

      final inward = _inwardNormal(tangent.vector, center, tangent.position);
      final perp = _normalizeOffset(tangent.vector);
      final travel = phase * size.height * 0.38;
      final emberPos = tangent.position +
          inward * travel +
          perp * (math.sin(phase * math.pi * 4) * 4);

      canvas.drawCircle(
        emberPos,
        1.1 + (i % 3) * 0.45,
        Paint()
          ..color = Color.lerp(
            const Color(0xFFFFEB3B),
            const Color(0xFFFF7043),
            phase,
          )!
              .withValues(alpha: (1 - phase) * 0.75),
      );
    }
  }

  Offset _inwardNormal(Offset tangent, Offset center, Offset point) {
    final n1 = _normalizeOffset(Offset(-tangent.dy, tangent.dx));
    final n2 = _normalizeOffset(Offset(tangent.dy, -tangent.dx));
    final toCenter = center - point;
    return (n1.dx * toCenter.dx + n1.dy * toCenter.dy) >= 0 ? n1 : n2;
  }

  Offset _normalizeOffset(Offset value) {
    final length = value.distance;
    if (length <= 0.0001) return Offset.zero;
    return Offset(value.dx / length, value.dy / length);
  }

  void _drawFlameTongueOnBorder({
    required Canvas canvas,
    required Offset base,
    required Offset inward,
    required Offset perp,
    required double width,
    required double height,
    required double wobble,
  }) {
    final inwardNorm = _normalizeOffset(inward);
    final perpNorm = _normalizeOffset(perp);
    final halfW = width * 0.5;

    final left = base - perpNorm * halfW;
    final right = base + perpNorm * halfW;
    final tip = base +
        inwardNorm * height +
        perpNorm * (wobble * width * 1.4);

    final controlLeft = base +
        perpNorm * (-width * 0.15 + wobble * width * 0.6) +
        inwardNorm * (height * 0.55);
    final controlRight = base +
        perpNorm * (width * 0.2 - wobble * width * 0.4) +
        inwardNorm * (height * 0.5);

    final path = Path()
      ..moveTo(left.dx, left.dy)
      ..quadraticBezierTo(controlLeft.dx, controlLeft.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(controlRight.dx, controlRight.dy, right.dx, right.dy)
      ..close();

    final bounds = path.getBounds();
    final halfWBounds = bounds.width / 2;
    final halfHBounds = bounds.height / 2;
    final cx = bounds.center.dx;
    final cy = bounds.center.dy;

    double alignX(Offset p) =>
        halfWBounds <= 0 ? 0 : ((p.dx - cx) / halfWBounds).clamp(-1.0, 1.0);
    double alignY(Offset p) =>
        halfHBounds <= 0 ? 0 : ((p.dy - cy) / halfHBounds).clamp(-1.0, 1.0);

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment(alignX(base), alignY(base)),
          end: Alignment(alignX(tip), alignY(tip)),
          colors: const [
            Color(0xE6FF5722),
            Color(0xCCFF9800),
            Color(0xAAFFEB3B),
            Color(0x00FFFDE7),
          ],
          stops: [0, 0.35, 0.68, 1],
        ).createShader(bounds),
    );
  }

  void _drawSnowflake(Canvas canvas, Offset center, double size, Color color) {
    final armPaint = Paint()
      ..color = color
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round;
    final branchPaint = Paint()
      ..color = color
      ..strokeWidth = 0.65
      ..strokeCap = StrokeCap.round;
    for (var arm = 0; arm < 6; arm++) {
      final angle = arm * math.pi / 3;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center, center + dir * size, armPaint);
      final branch = dir * size * 0.55;
      final normal = Offset(-dir.dy, dir.dx);
      canvas.drawLine(
        center + branch,
        center + branch + normal * size * 0.28,
        branchPaint,
      );
      canvas.drawLine(
        center + branch,
        center + branch - normal * size * 0.28,
        branchPaint,
      );
    }
    canvas.drawCircle(center, 0.8, Paint()..color = color);
  }

  void _paintConfetti(Canvas canvas, Size size) {
    const colors = [
      Color(0x66FF6B9D),
      Color(0x664FC3F7),
      Color(0x66FBBF24),
      Color(0x66A78BFA),
    ];
    for (var i = 0; i < 18; i++) {
      final x = (i * 41 + progress * size.width * 0.5) % size.width;
      final y = (i * 29 + progress * size.height * 1.2) % size.height;
      final rect = Rect.fromCenter(
        center: Offset(x, y),
        width: 3,
        height: 5,
      );
      canvas.drawRect(
        rect,
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  void _paintCosmic(Canvas canvas, Size size) {
    _paintAurora(canvas, size);
    for (var i = 0; i < 20; i++) {
      final phase = (progress * 0.6 + i * 0.05) % 1.0;
      final alpha = (math.sin(phase * math.pi * 2) * 0.5 + 0.5) * 0.9;
      final center = Offset(
        _particles[i % _particles.length].dx * size.width,
        _particles[i % _particles.length].dy * size.height,
      );
      canvas.drawCircle(
        center,
        1 + (i % 2),
        Paint()..color = AppColors.surfaceLight.withValues(alpha: alpha),
      );
    }
  }

  void _paintRipple(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final phase = (progress + i * 0.28) % 1.0;
      final radius = phase * size.shortestSide * 0.55;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = accentColor.withValues(alpha: (1 - phase) * 0.35);
      canvas.drawCircle(center, radius, paint);
    }
  }

  void _paintDiamond(Canvas canvas, Size size) {
    for (var i = 0; i < _particles.length; i++) {
      final phase = (progress + i * 0.09) % 1.0;
      final alpha = math.pow(math.sin(phase * math.pi), 2).toDouble() * 0.85;
      final center = Offset(
        _particles[i].dx * size.width,
        _particles[i].dy * size.height,
      );
      _drawDiamond(canvas, center, 4, accentColor.withValues(alpha: alpha));
    }
  }

  void _paintSunset(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0x33FF7043),
          const Color(0x22FFAB40),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintFrost(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceLight.withValues(alpha: 0.28)
      ..strokeWidth = 1.2;
    final corners = [
      Offset(8, 8),
      Offset(size.width - 8, 8),
      Offset(8, size.height - 8),
      Offset(size.width - 8, size.height - 8),
    ];
    for (final corner in corners) {
      canvas.drawLine(corner, corner + const Offset(10, 0), paint);
      canvas.drawLine(corner, corner + const Offset(0, 10), paint);
    }
  }

  void _paintMatrix(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x4439FF14)
      ..strokeWidth = 1;
    for (var col = 0; col < 10; col++) {
      final x = col * (size.width / 10) + 4;
      final offset = (progress + col * 0.08) % 1.0;
      for (var row = 0; row < 6; row++) {
        final y = ((row * 0.18 + offset) % 1.0) * size.height;
        canvas.drawLine(Offset(x, y), Offset(x, y + 8), paint);
      }
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.7, center.dy)
      ..lineTo(center.dx, center.dy + size)
      ..lineTo(center.dx - size * 0.7, center.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.45;
      final angle = (i * math.pi / points) - math.pi / 2;
      final point = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawSparkleCross(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center - Offset(size, 0), center + Offset(size, 0), paint);
    canvas.drawLine(center - Offset(0, size), center + Offset(0, size), paint);
    canvas.drawCircle(center, 1.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CardEffectPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.effect != effect ||
        oldDelegate.accentColor != accentColor;
  }
}
