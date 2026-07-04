import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';

/// LinkedIn tarzı yatay aksiyon butonları.
class SavedCardProfileActionBar extends StatelessWidget {
  const SavedCardProfileActionBar({
    super.key,
    required this.hasEmail,
    required this.hasPhone,
    required this.hasLinkedIn,
    this.onEmail,
    this.onPhone,
    this.onLinkedIn,
    this.onMore,
  });

  final bool hasEmail;
  final bool hasPhone;
  final bool hasLinkedIn;
  final VoidCallback? onEmail;
  final VoidCallback? onPhone;
  final VoidCallback? onLinkedIn;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final buttons = <Widget>[];

    void addButton(Widget button) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 8));
      buttons.add(Expanded(child: button));
    }

    if (hasEmail) {
      addButton(
        _ProfileActionButton(
          label: context.l10n.ePosta,
          icon: Icons.email_outlined,
          filled: true,
          onTap: onEmail,
        ),
      );
    } else if (hasPhone) {
      addButton(
        _ProfileActionButton(
          label: context.l10n.telefon,
          icon: Icons.phone_outlined,
          filled: true,
          onTap: onPhone,
        ),
      );
    } else if (hasLinkedIn) {
      addButton(
        _ProfileActionButton(
          label: context.l10n.linkedin,
          icon: Icons.link_rounded,
          filled: true,
          onTap: onLinkedIn,
        ),
      );
    }

    if (hasPhone && hasEmail) {
      addButton(
        _ProfileActionButton(
          label: context.l10n.telefon,
          icon: Icons.phone_outlined,
          filled: false,
          onTap: onPhone,
        ),
      );
    }

    if (hasLinkedIn && (hasEmail || hasPhone)) {
      addButton(
        _ProfileActionButton(
          label: context.l10n.linkedin,
          icon: Icons.link_rounded,
          filled: false,
          onTap: onLinkedIn,
        ),
      );
    }

    if (buttons.isEmpty && onMore == null) {
      return const SizedBox.shrink();
    }

    if (onMore != null) {
      buttons.add(const SizedBox(width: 8));
      buttons.add(
        _ProfileMoreButton(onTap: onMore),
      );
    }

    return ColoredBox(
      color: AppColors.profileDetailSurface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: buttons,
        ),
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
            softWrap: false,
            overflow: TextOverflow.visible,
            style: labelStyle,
          ),
        ),
      ],
    );

    if (filled) {
      return FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.linkedInBrand,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: content,
      );
    }

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.linkedInBrand,
        side: BorderSide(
          color: AppColors.linkedInBrand.withValues(alpha: 0.85),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: content,
    );
  }
}

class _ProfileMoreButton extends StatelessWidget {
  const _ProfileMoreButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondaryDark,
          side: const BorderSide(color: AppColors.profileDetailBorder),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        child: const Icon(Icons.more_horiz_rounded, size: 22),
      ),
    );
  }
}
