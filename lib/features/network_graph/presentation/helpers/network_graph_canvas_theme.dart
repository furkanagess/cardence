import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/card_watermark.dart';

/// Ağ grafiği çizim alanı — tema uyumlu zemin ve ızgara.
abstract final class NetworkGraphCanvasTheme {
  static Brightness brightnessOf(BuildContext context) =>
      Theme.of(context).brightness;

  static bool isDark(BuildContext context) =>
      brightnessOf(context) == Brightness.dark;

  static Color background(BuildContext context) =>
      AppColors.graphCanvasBackgroundFor(brightnessOf(context));

  static BoxDecoration backgroundDecoration(BuildContext context) =>
      BoxDecoration(color: background(context));

  static BoxDecoration fullscreenButtonDecoration(
    BuildContext context,
    Color accent,
  ) {
    final brightness = brightnessOf(context);
    return BoxDecoration(
      color: AppColors.graphNodeLabelBackgroundFor(brightness),
      shape: BoxShape.circle,
      border: Border.all(
        color: AppColors.graphNodeLabelBorderFor(brightness),
      ),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: isDark(context) ? 0.2 : 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static TextStyle nodeLabelStyle(TextTheme textTheme, Brightness brightness) =>
      textTheme.labelSmall?.copyWith(
        color: AppColors.graphCanvasPrimaryTextFor(brightness),
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.2,
      ) ??
      TextStyle(
        color: AppColors.graphCanvasPrimaryTextFor(brightness),
        fontWeight: FontWeight.w600,
        fontSize: 11,
      );

  static Color nodeLabelBackground(Brightness brightness) =>
      AppColors.graphNodeLabelBackgroundFor(brightness);

  static Color nodeLabelBorder(Brightness brightness) =>
      AppColors.graphNodeLabelBorderFor(brightness);
}

/// Hafif nokta ızgarası — düğüm ve kenarları zeminde okunaklı kılar.
class NetworkGraphGridPainter extends CustomPainter {
  const NetworkGraphGridPainter({
    this.spacing = 28,
    this.dotRadius = 0.85,
    this.brightness = Brightness.dark,
  });

  final double spacing;
  final double dotRadius;
  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = AppColors.graphCanvasGridFor(brightness);
    final accentPaint = Paint()
      ..color = AppColors.graphCanvasGridAccentFor(brightness);

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
  bool shouldRepaint(covariant NetworkGraphGridPainter oldDelegate) =>
      oldDelegate.brightness != brightness ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}

/// Zemin, ızgara ve Cardence filigranı — grafik çizim alanı arka planı.
class NetworkGraphCanvasBackground extends StatelessWidget {
  const NetworkGraphCanvasBackground({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final brightness = NetworkGraphCanvasTheme.brightnessOf(context);
    final background = NetworkGraphCanvasTheme.background(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: background),
        CustomPaint(
          painter: NetworkGraphGridPainter(brightness: brightness),
        ),
        CardWatermark(
          surfaceColor: background,
          variant: CardWatermarkVariant.graphCanvas,
        ),
        if (child != null) child!,
      ],
    );
  }
}
