import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Birleşme / bağlantı animasyonu düğümü.
class CardenceConnectNode {
  const CardenceConnectNode({
    required this.icon,
    required this.direction,
  });

  final IconData icon;

  /// Merkeze göre başlangıç yönü (normalize edilmiş vektör).
  final Offset direction;
}

/// Cardence logo merkezli «connect» animasyonu.
///
/// Üç düğüm merkeze yaklaşır, çizgilerle bağlanır; logo belirir.
/// [repeat] true ise döngü halinde tekrarlar.
class CardenceConnectAnimation extends StatefulWidget {
  const CardenceConnectAnimation({
    super.key,
    this.size = 220,
    this.repeat = true,
    this.duration = const Duration(milliseconds: 1500),
    this.pauseBetweenCycles = const Duration(milliseconds: 700),
    this.logoAssetPath = 'assets/icons/cardence_logo_splash_white.png',
    this.nodes,
    this.nodeBadgeSize,
  });

  /// Kare alan genişliği / yüksekliği.
  final double size;

  /// Animasyon tamamlandıktan sonra yeniden başlasın mı.
  final bool repeat;

  final Duration duration;

  /// Döngüler arası bekleme (yalnızca [repeat] true iken).
  final Duration pauseBetweenCycles;

  final String logoAssetPath;

  /// Varsayılan: kişi, QR, bağlantı düğümleri.
  final List<CardenceConnectNode>? nodes;

  /// Dış düğüm rozeti çapı; null ise [size] * 0.26.
  final double? nodeBadgeSize;

  static const List<CardenceConnectNode> defaultNodes = [
    CardenceConnectNode(
      icon: Icons.person_outline_rounded,
      direction: Offset(-1, 0.15),
    ),
    CardenceConnectNode(
      icon: Icons.qr_code_2_rounded,
      direction: Offset(1, 0.1),
    ),
    CardenceConnectNode(
      icon: Icons.hub_outlined,
      direction: Offset(0, -1),
    ),
  ];

  @override
  State<CardenceConnectAnimation> createState() =>
      _CardenceConnectAnimationState();
}

class _CardenceConnectAnimationState extends State<CardenceConnectAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _merge;
  late final Animation<double> _lines;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _pulse;
  late final List<CardenceConnectNode> _nodes;

  @override
  void initState() {
    super.initState();
    _nodes = widget.nodes ?? CardenceConnectAnimation.defaultNodes;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _merge = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.7, curve: Curves.easeOutCubic),
    );
    _lines = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.82, curve: Curves.easeOut),
    );
    _logoScale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1, curve: Curves.easeOutBack),
    );
    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.75, curve: Curves.easeOut),
    );
    _pulse = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.78, 1, curve: Curves.easeInOut),
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
  void didUpdateWidget(CardenceConnectAnimation oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nodeSize = widget.nodeBadgeSize ?? widget.size * 0.26;
    final nodeBadgeRadius = nodeSize / 2;
    final outerRadius = widget.size * 0.5;
    final innerRadius = widget.size * 0.34;
    final logoSize = widget.size * 0.64;
    final imageSize = logoSize * 0.82;
    final center = widget.size / 2;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final mergeT = _merge.value;
          final lineT = _lines.value;
          final scale = 0.72 + _logoScale.value * 0.28;
          final pulse = 1 + _pulse.value * 0.04;
          final ringOpacity = (lineT * 0.35).clamp(0.0, 1.0);

          final nodeCenters = <Offset>[];
          for (final node in _nodes) {
            final start = Offset(
              center + node.direction.dx * outerRadius,
              center + node.direction.dy * outerRadius,
            );
            final end = Offset(
              center + node.direction.dx * innerRadius,
              center + node.direction.dy * innerRadius,
            );
            nodeCenters.add(Offset.lerp(start, end, mergeT)!);
          }

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ConnectLinesPainter(
                  nodeCenters: nodeCenters,
                  hubCenter: Offset(center, center),
                  hubRadius: logoSize * 0.55,
                  progress: lineT,
                  lineColor: colorScheme.primary.withValues(alpha: 0.45),
                  hubColor: colorScheme.primary.withValues(alpha: ringOpacity),
                ),
              ),
              ...List.generate(_nodes.length, (i) {
                final node = _nodes[i];
                final pos = nodeCenters[i];
                final nodeFade = (1 - mergeT * 0.75).clamp(0.15, 1.0);
                final nodeScale = (1 - mergeT * 0.35).clamp(0.55, 1.0);

                return Positioned(
                  left: pos.dx - nodeBadgeRadius,
                  top: pos.dy - nodeBadgeRadius,
                  child: Opacity(
                    opacity: nodeFade,
                    child: Transform.scale(
                      scale: nodeScale,
                      child: _NodeBadge(
                        icon: node.icon,
                        size: nodeSize,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                );
              }),
              Opacity(
                opacity: _logoOpacity.value.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale * pulse,
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.35 : 0.28,
                          ),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.textOnPrimary.withValues(
                          alpha: 0.15 + lineT * 0.2,
                        ),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        widget.logoAssetPath,
                        width: imageSize,
                        height: imageSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.credit_card_rounded,
                          size: imageSize * 0.85,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
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

class _NodeBadge extends StatelessWidget {
  const _NodeBadge({
    required this.icon,
    required this.size,
    required this.colorScheme,
  });

  final IconData icon;
  final double size;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.48;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: iconSize, color: colorScheme.primary),
    );
  }
}

class _ConnectLinesPainter extends CustomPainter {
  _ConnectLinesPainter({
    required this.nodeCenters,
    required this.hubCenter,
    required this.hubRadius,
    required this.progress,
    required this.lineColor,
    required this.hubColor,
  });

  final List<Offset> nodeCenters;
  final Offset hubCenter;
  final double hubRadius;
  final double progress;
  final Color lineColor;
  final Color hubColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final node in nodeCenters) {
      final end = Offset.lerp(node, hubCenter, progress)!;
      canvas.drawLine(node, end, linePaint);
    }

    if (progress > 0.5) {
      final ringPaint = Paint()
        ..color = hubColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(hubCenter, hubRadius * progress, ringPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectLinesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.nodeCenters != nodeCenters;
  }
}
