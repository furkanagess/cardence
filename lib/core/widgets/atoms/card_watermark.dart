import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Cardence logosu — kart yüzeyi veya tam ekran filigran.
enum CardWatermarkVariant {
  /// Kartvizit önizlemesi (kompakt).
  cardCompact,

  /// Kartvizit önizlemesi (normal).
  card,

  /// Uygulama ekranı arka planı.
  screen,
}

/// Cardence logosu — merkezi filigran.
class CardWatermark extends StatelessWidget {
  const CardWatermark({
    super.key,
    required this.surfaceColor,
    this.variant = CardWatermarkVariant.card,
  });

  final Color surfaceColor;
  final CardWatermarkVariant variant;

  static const String assetPath = 'assets/icons/cardence_logo-removebg.png';

  double get _size {
    switch (variant) {
      case CardWatermarkVariant.cardCompact:
        return 130;
      case CardWatermarkVariant.card:
        return 168;
      case CardWatermarkVariant.screen:
        return 240;
    }
  }

  double get _opacity {
    final isDark = surfaceColor.computeLuminance() < 0.35;
    switch (variant) {
      case CardWatermarkVariant.cardCompact:
      case CardWatermarkVariant.card:
        return isDark ? 0.12 : 0.08;
      case CardWatermarkVariant.screen:
        return isDark ? 0.07 : 0.05;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = surfaceColor.computeLuminance() < 0.35;

    return IgnorePointer(
      child: Center(
        child: Opacity(
          opacity: _opacity,
          child: Image.asset(
            assetPath,
            width: _size,
            height: _size,
            fit: BoxFit.contain,
            color: isDark ? AppColors.surfaceLight : AppColors.primary,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
