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

  static const double chipSize = 36;
  static const double chipRadius = 10;
  static const double chipGap = 8;
  static const double horizontalPadding = 14;

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

    final contactChips = <Widget>[];

    void addContactChip(Widget chip) {
      if (contactChips.isNotEmpty) {
        contactChips.add(const SizedBox(width: chipGap));
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
          onTap: contactFieldsTappable
              ? () => ContactLauncher.launchWebUrl(context, value)
              : null,
          tooltip: context.l10n.linkedin,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CardPreviewActionStrip.horizontalPadding,
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
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    Widget chip = DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          CardPreviewActionStrip.chipRadius,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            CardPreviewActionStrip.chipRadius,
          ),
          child: SizedBox(
            width: CardPreviewActionStrip.chipSize,
            height: CardPreviewActionStrip.chipSize,
            child: Center(
              child: Icon(
                icon,
                size: 20,
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
