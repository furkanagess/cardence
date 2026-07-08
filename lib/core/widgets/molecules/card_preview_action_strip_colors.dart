import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Kart yüzeyi ve vurgu rengine göre aksiyon şeridi renkleri.
class CardPreviewActionStripColors {
  const CardPreviewActionStripColors({
    required this.iconColor,
    required this.chipBackground,
    required this.chipBorder,
    required this.detailChipBackground,
    required this.detailIconColor,
  });

  final Color iconColor;
  final Color chipBackground;
  final Color chipBorder;
  final Color detailChipBackground;
  final Color detailIconColor;

  static CardPreviewActionStripColors resolve({
    required Color cardSurface,
    Color? accentColor,
  }) {
    final isLightCard = cardSurface.computeLuminance() > 0.5;
    final onSurface =
        isLightCard ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final onSurfaceVariant =
        isLightCard ? AppColors.textSecondary : AppColors.textSecondaryDark;

    var iconColor = accentColor ?? onSurfaceVariant;
    if (_contrastRatio(iconColor, cardSurface) < 2.8) {
      iconColor = onSurface;
    }

    final chipBackground = Color.alphaBlend(
      iconColor.withValues(alpha: isLightCard ? 0.14 : 0.22),
      cardSurface,
    );
    final chipBorder = iconColor.withValues(alpha: isLightCard ? 0.34 : 0.44);

    final detailChipBackground = Color.alphaBlend(
      iconColor.withValues(alpha: isLightCard ? 0.26 : 0.34),
      cardSurface,
    );

    var detailIconColor = iconColor;
    if (_contrastRatio(detailIconColor, detailChipBackground) < 2.8) {
      detailIconColor = onSurface;
    }

    return CardPreviewActionStripColors(
      iconColor: iconColor,
      chipBackground: chipBackground,
      chipBorder: chipBorder,
      detailChipBackground: detailChipBackground,
      detailIconColor: detailIconColor,
    );
  }

  static double _contrastRatio(Color foreground, Color background) {
    final fg = foreground.computeLuminance();
    final bg = background.computeLuminance();
    final lighter = fg > bg ? fg : bg;
    final darker = fg > bg ? bg : fg;
    return (lighter + 0.05) / (darker + 0.05);
  }
}
