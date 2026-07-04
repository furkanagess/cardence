import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/card_watermark.dart';

/// Ağ grafiği çizim alanı — siyah zemin ve ızgara.
abstract final class NetworkGraphCanvasTheme {
  static const Color background = AppColors.graphCanvasBackground;

  static BoxDecoration get backgroundDecoration => const BoxDecoration(
        color: background,
      );

  static BoxDecoration fullscreenButtonDecoration(Color accent) => BoxDecoration(
        color: AppColors.graphNodeLabelBackground,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.graphNodeLabelBorder),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static TextStyle nodeLabelStyle(TextTheme textTheme) =>
      textTheme.labelSmall?.copyWith(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.2,
      ) ??
      const TextStyle(
        color: AppColors.textPrimaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      );
}

/// Hafif nokta ızgarası — düğüm ve kenarları siyah zeminde okunaklı kılar.
class NetworkGraphGridPainter extends CustomPainter {
  const NetworkGraphGridPainter({
    this.spacing = 28,
    this.dotRadius = 0.85,
  });

  final double spacing;
  final double dotRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = AppColors.graphCanvasGrid;
    final accentPaint = Paint()..color = AppColors.graphCanvasGridAccent;

    for (var x = spacing; x < size.width; x += spacing) {
      for (var y = spacing; y < size.height; y += spacing) {
        final isMajor =
            (x / spacing).round() % 4 == 0 && (y / spacing).round() % 4 == 0;
        canvas.drawCircle(
          Offset(x, y),
          isMajor ? dotRadius + 0.35 : dotRadius,
          isMajor ? accentPaint : dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant NetworkGraphGridPainter oldDelegate) => false;
}

/// Siyah zemin, ızgara ve Cardence filigranı — grafik çizim alanı arka planı.
class NetworkGraphCanvasBackground extends StatelessWidget {
  const NetworkGraphCanvasBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: NetworkGraphCanvasTheme.background),
        const CustomPaint(painter: NetworkGraphGridPainter()),
        const CardWatermark(
          surfaceColor: NetworkGraphCanvasTheme.background,
          variant: CardWatermarkVariant.graphCanvas,
        ),
        if (child != null) child!,
      ],
    );
  }
}
