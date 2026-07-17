import 'package:flutter/material.dart';

import '../../l10n/l10n_extensions.dart';
import '../../utils/contact_launcher.dart';
import 'card_preview_action_strip_colors.dart';

/// Kart önizlemesinde detay ve iletişim kısayolları (flip butonu yerine).
class CardPreviewActionStrip extends StatelessWidget {
  const CardPreviewActionStrip({
    super.key,
    required this.cardSurfaceColor,
    this.accentColor,
    this.onDetailTap,
    this.email,
    this.phone,
    this.linkedin,
    this.contactFieldsTappable = true,
    this.iconColor,
    this.chipBackground,
    this.scale = 1.0,
  });

  final Color cardSurfaceColor;
  final Color? accentColor;
  final VoidCallback? onDetailTap;
  final String? email;
  final String? phone;
  final String? linkedin;
  final bool contactFieldsTappable;

  /// Manuel override; verilmezse [cardSurfaceColor] + [accentColor] ile türetilir.
  final Color? iconColor;
  final Color? chipBackground;

  /// Kart yüzü genişliğine göre ölçek (bkz. CardFaceMetrics). Sabitler tasarım
  /// referansı olarak kalır; build içinde `scale * const` uygulanır.
  final double scale;

  static const double chipSize = 36;
  static const double chipRadius = 10;
  static const double chipGap = 8;
  static const double horizontalPadding = 14;

  /// Verilen ölçekte kullanılacak fiili chip boyutu (dış çağırıcılar için).
  static double scaledChipSize(double scale) => chipSize * scale;

  bool get _hasEmail => email?.trim().isNotEmpty == true;
  bool get _hasPhone => phone?.trim().isNotEmpty == true;
  bool get _hasLinkedIn => linkedin?.trim().isNotEmpty == true;

  bool get _hasAnyAction =>
      onDetailTap != null || _hasEmail || _hasPhone || _hasLinkedIn;

  @override
  Widget build(BuildContext context) {
    if (!_hasAnyAction) return const SizedBox.shrink();

    final palette = CardPreviewActionStripColors.resolve(
      cardSurface: cardSurfaceColor,
      accentColor: accentColor,
    );
    final resolvedIconColor = iconColor ?? palette.iconColor;
    final resolvedChipBackground = chipBackground ?? palette.chipBackground;
    final resolvedChipBorder = palette.chipBorder;

    final chipGapScaled = chipGap * scale;

    final contactChips = <Widget>[];

    void addContactChip(Widget chip) {
      if (contactChips.isNotEmpty) {
        contactChips.add(SizedBox(width: chipGapScaled));
      }
      contactChips.add(chip);
    }

    if (_hasEmail) {
      final value = email!.trim();
      addContactChip(
        _ActionChip(
          icon: Icons.mail_outline_rounded,
          iconColor: resolvedIconColor,
          backgroundColor: resolvedChipBackground,
          borderColor: resolvedChipBorder,
          scale: scale,
          onTap: contactFieldsTappable
              ? () => ContactLauncher.launchEmail(context, value)
              : null,
          tooltip: context.l10n.ePosta,
        ),
      );
    }

    if (_hasPhone) {
      final value = phone!.trim();
      addContactChip(
        _ActionChip(
          icon: Icons.phone_outlined,
          iconColor: resolvedIconColor,
          backgroundColor: resolvedChipBackground,
          borderColor: resolvedChipBorder,
          scale: scale,
          onTap: contactFieldsTappable
              ? () => ContactLauncher.launchPhone(context, value)
              : null,
          tooltip: context.l10n.telefon,
        ),
      );
    }

    if (_hasLinkedIn) {
      final value = linkedin!.trim();
      addContactChip(
        _ActionChip(
          icon: Icons.link_rounded,
          iconColor: resolvedIconColor,
          backgroundColor: resolvedChipBackground,
          borderColor: resolvedChipBorder,
          scale: scale,
          onTap: contactFieldsTappable
              ? () => ContactLauncher.launchWebUrl(context, value)
              : null,
          tooltip: context.l10n.linkedin,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: CardPreviewActionStrip.horizontalPadding * scale,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (contactChips.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: contactChips,
            ),
          if (contactChips.isNotEmpty && onDetailTap != null) const Spacer(),
          if (onDetailTap != null)
            _ActionChip(
              icon: Icons.north_east_rounded,
              iconColor: palette.detailIconColor,
              backgroundColor: palette.detailChipBackground,
              borderColor: palette.chipBorder,
              scale: scale,
              onTap: onDetailTap,
              tooltip: context.l10n.kartDetay,
            ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    this.onTap,
    this.tooltip,
    this.scale = 1.0,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final String? tooltip;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final chipSize = CardPreviewActionStrip.chipSize * scale;
    final chipRadius = CardPreviewActionStrip.chipRadius * scale;

    Widget chip = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(chipRadius),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(chipRadius),
          child: SizedBox(
            width: chipSize,
            height: chipSize,
            child: Center(
              child: Icon(
                icon,
                size: 20 * scale,
                color: iconColor.withValues(
                  alpha: enabled ? 1 : 0.45,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      return Tooltip(
        message: tooltip!,
        child: chip,
      );
    }

    return chip;
  }
}
