import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../helpers/saved_card_detail_theme.dart';

/// Profil hızlı aksiyonları: e-posta, telefon, LinkedIn, web sitesi; sonda paylaş ikonu.
class SavedCardProfileActionBar extends StatelessWidget {
  const SavedCardProfileActionBar({
    super.key,
    required this.hasEmail,
    required this.hasPhone,
    required this.hasLinkedIn,
    this.hasWebsite = false,
    this.showShare = false,
    this.onEmail,
    this.onPhone,
    this.onLinkedIn,
    this.onWebsite,
    this.onShare,
  });

  final bool hasEmail;
  final bool hasPhone;
  final bool hasLinkedIn;
  final bool hasWebsite;
  final bool showShare;
  final VoidCallback? onEmail;
  final VoidCallback? onPhone;
  final VoidCallback? onLinkedIn;
  final VoidCallback? onWebsite;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    final contactCount = [
      hasEmail,
      hasPhone,
      hasLinkedIn,
      hasWebsite,
    ].where((visible) => visible).length;

    if (hasEmail) {
      buttons.add(
        _ProfileActionButton(
          label: context.l10n.ePosta,
          icon: Icons.mail_outline_rounded,
          filled: contactCount == 1,
          onTap: onEmail,
        ),
      );
    }

    if (hasPhone) {
      buttons.add(
        _ProfileActionButton(
          label: context.l10n.telefon,
          icon: Icons.phone_outlined,
          filled: contactCount == 1,
          onTap: onPhone,
        ),
      );
    }

    if (hasLinkedIn) {
      buttons.add(
        _ProfileActionButton(
          label: context.l10n.linkedin,
          icon: Icons.link_rounded,
          filled: contactCount == 1,
          onTap: onLinkedIn,
        ),
      );
    }

    if (hasWebsite) {
      buttons.add(
        _ProfileActionButton(
          label: context.l10n.webSitesi,
          icon: Icons.language_rounded,
          filled: contactCount == 1,
          onTap: onWebsite,
        ),
      );
    }

    if (buttons.isEmpty && !showShare) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...buttons,
          if (showShare)
            _ProfileIconButton(
              icon: Icons.share_outlined,
              tooltip: context.l10n.kartPayla,
              onTap: onShare,
            ),
        ],
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final surface = SavedCardDetailTheme.surface(context);
    final outline = SavedCardDetailTheme.outline(context);
    final labelStyle = textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.1,
    );

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: labelStyle,
          ),
        ),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: content,
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        backgroundColor: surface,
        side: BorderSide(color: outline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: content,
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  const _ProfileIconButton({
    required this.icon,
    required this.tooltip,
    this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = SavedCardDetailTheme.surface(context);
    final outline = SavedCardDetailTheme.outline(context);

    return SizedBox(
      width: 48,
      height: 44,
      child: Tooltip(
        message: tooltip,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: surface,
            side: BorderSide(color: outline),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Icon(icon, size: 22),
        ),
      ),
    );
  }
}
