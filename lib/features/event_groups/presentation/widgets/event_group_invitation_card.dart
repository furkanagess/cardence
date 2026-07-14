import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/event_group_invitation.dart';
import '../helpers/event_group_invitation_formatter.dart';
import '../helpers/event_group_list_display_formatter.dart';
import '../helpers/event_group_meta_formatter.dart';
import 'event_group_cover_thumbnail.dart';

class EventGroupInvitationCard extends StatelessWidget {
  const EventGroupInvitationCard({
    super.key,
    required this.invitation,
    required this.onAccept,
    required this.onReject,
    this.isResponding = false,
    this.canAccept = true,
  });

  final EventGroupInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isResponding;
  final bool canAccept;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;

    final description = invitation.description?.trim();
    final location = EventGroupListDisplayFormatter.primaryCityFromLocation(
          invitation.location,
        ) ??
        invitation.location?.trim();
    final schedule = EventGroupMetaFormatter.formatRange(
      invitation.startAt,
      invitation.endAt,
    );
    final remaining = EventGroupInvitationFormatter.eventStartRemainingLabel(
      l10n,
      invitation.startAt,
      invitation.endAt,
    );
    final cardLabel = invitation.cardDisplayName?.trim().isNotEmpty == true
        ? invitation.cardDisplayName!.trim()
        : invitation.cardId;

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventGroupCoverThumbnail(
                  photoUrl: invitation.photoUrl,
                  size: 56,
                  borderRadius: 12,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.eventName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.eventInvitationInvitedBy(invitation.inviterName),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InvitationDetailRow(
              icon: Icons.schedule_rounded,
              label: schedule,
            ),
            if (location != null && location.isNotEmpty) ...[
              const SizedBox(height: 6),
              _InvitationDetailRow(
                icon: Icons.place_outlined,
                label: location,
              ),
            ],
            const SizedBox(height: 6),
            _InvitationDetailRow(
              icon: Icons.hourglass_bottom_rounded,
              label: remaining,
            ),
            const SizedBox(height: 6),
            _InvitationDetailRow(
              icon: Icons.badge_outlined,
              label: l10n.eventInvitationCardLabel(cardLabel),
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: isDark ? 0.35 : 0.55,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.eventAboutSectionLabel.toUpperCase(),
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.4,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!canAccept) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    l10n.eventInvitationQuotaFull,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            _InvitationResponseActions(
              acceptLabel: canAccept
                  ? l10n.eventInvitationAccept
                  : l10n.eventInvitationUpgradeToAccept,
              rejectLabel: l10n.eventInvitationReject,
              isResponding: isResponding,
              canAccept: canAccept,
              onAccept: onAccept,
              onReject: onReject,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationDetailRow extends StatelessWidget {
  const _InvitationDetailRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
          ),
        ),
      ],
    );
  }
}

class _InvitationResponseActions extends StatelessWidget {
  const _InvitationResponseActions({
    required this.acceptLabel,
    required this.rejectLabel,
    required this.isResponding,
    required this.canAccept,
    required this.onAccept,
    required this.onReject,
  });

  final String acceptLabel;
  final String rejectLabel;
  final bool isResponding;
  final bool canAccept;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  static const _actionButtonHeight = 42.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const buttonPadding = EdgeInsets.symmetric(horizontal: 12);

    return Row(
      children: [
        Expanded(
          child: CustomButton.outlined(
            label: rejectLabel,
            height: _actionButtonHeight,
            onPressed: isResponding ? null : onReject,
            enabled: !isResponding,
            fullWidth: true,
            visualDensity: VisualDensity.compact,
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              backgroundColor: colorScheme.surface,
              side: BorderSide(
                color: isDark
                    ? AppColors.outlineDark.withValues(alpha: 0.45)
                    : AppColors.outlineVariant,
              ),
              minimumSize: const Size(0, _actionButtonHeight),
              maximumSize: const Size(double.infinity, _actionButtonHeight),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: buttonPadding,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomButton(
            label: acceptLabel,
            height: _actionButtonHeight,
            onPressed: isResponding ? null : onAccept,
            enabled: !isResponding,
            isLoading: isResponding,
            fullWidth: true,
            visualDensity: VisualDensity.compact,
            style: FilledButton.styleFrom(
              backgroundColor: canAccept
                  ? AppColors.primary
                  : AppColors.secondary,
              foregroundColor: AppColors.textOnPrimary,
              minimumSize: const Size(0, _actionButtonHeight),
              maximumSize: const Size(double.infinity, _actionButtonHeight),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: buttonPadding,
            ),
          ),
        ),
      ],
    );
  }
}
