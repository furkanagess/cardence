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

  /// Ağ grafiği siyah zemin.
  graphCanvas,
}

/// Cardence logosu — merkezi filigran.
class CardWatermark extends StatelessWidget {
  const CardWatermark({
    super.key,
    required this.surfaceColor,
    this.variant = CardWatermarkVariant.card,
    this.size,
  });

  final Color surfaceColor;
  final CardWatermarkVariant variant;

  /// Verilirse variant'a bağlı varsayılan boyut yerine kullanılır.
  final double? size;

  static const String assetPath = 'assets/icons/cardence_logo-removebg.png';

  double get _size {
    if (size != null) return size!;
    switch (variant) {
      case CardWatermarkVariant.cardCompact:
        return 172;
      case CardWatermarkVariant.card:
        return 168;
      case CardWatermarkVariant.screen:
        return 240;
      case CardWatermarkVariant.graphCanvas:
        return 300;
    }
  }

  double get _opacity {
    final isDark = surfaceColor.computeLuminance() < 0.35;
    switch (variant) {
      case CardWatermarkVariant.cardCompact:
      case CardWatermarkVariant.card:
        return isDark ? 0.14 : 0.1;
      case CardWatermarkVariant.screen:
        return isDark ? 0.07 : 0.05;
      case CardWatermarkVariant.graphCanvas:
        return isDark ? 0.11 : 0.08;
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

/// Kart sağ üst köşesinde filigran tarzı Cardence logosu.
class CardenceCardCornerWatermark extends StatelessWidget {
  const CardenceCardCornerWatermark({
    super.key,
    required this.surfaceColor,
    this.compact = false,
    this.size,
  });

  final Color surfaceColor;
  final bool compact;
  final double? size;

  double get _size => size ?? (compact ? 52 : 112);

  double get _opacity {
    final isDark = surfaceColor.computeLuminance() < 0.35;
    return isDark ? 0.14 : 0.1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = surfaceColor.computeLuminance() < 0.35;

    return IgnorePointer(
      child: Opacity(
        opacity: _opacity,
        child: Image.asset(
          CardWatermark.assetPath,
          width: _size,
          height: _size,
          fit: BoxFit.contain,
          color: isDark ? AppColors.surfaceLight : AppColors.primary,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (_, __, ___) => Icon(
            Icons.credit_card_rounded,
            size: _size * 0.55,
            color: isDark ? AppColors.surfaceLight : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
