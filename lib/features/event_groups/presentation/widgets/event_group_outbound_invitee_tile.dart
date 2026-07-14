import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../domain/entities/event_group_outbound_invitation.dart';

class EventGroupOutboundInviteeTile extends StatelessWidget {
  const EventGroupOutboundInviteeTile({
    super.key,
    required this.invitation,
  });

  final EventGroupOutboundInvitation invitation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final title = invitation.cardTitle?.trim();
    final company = invitation.cardCompany?.trim();
    final subtitleParts = <String>[
      if (title != null && title.isNotEmpty) title,
      if (company != null && company.isNotEmpty) company,
      invitation.cardId,
    ];

    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            ProfileAvatar(
              photoUrl:
                  invitation.cardPhotoUrl ?? invitation.inviteePhotoUrl,
              displayName: invitation.displayName,
              size: 48,
              circular: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    invitation.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitleParts.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            EventGroupOutboundInviteStatusChip(invitation: invitation),
          ],
        ),
      ),
    );
  }
}

class EventGroupOutboundInviteStatusChip extends StatelessWidget {
  const EventGroupOutboundInviteStatusChip({
    super.key,
    required this.invitation,
  });

  final EventGroupOutboundInvitation invitation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    late final String label;
    late final Color bg;
    late final Color fg;

    if (invitation.isAccepted) {
      label = l10n.eventOutboundInviteStatusAccepted;
      bg = AppColors.success.withValues(alpha: 0.16);
      fg = AppColors.success;
    } else if (invitation.isRejected) {
      label = l10n.eventOutboundInviteStatusRejected;
      bg = AppColors.error.withValues(alpha: 0.14);
      fg = AppColors.error;
    } else if (invitation.expiresAt.isBefore(DateTime.now().toUtc())) {
      label = l10n.eventOutboundInviteStatusExpired;
      bg = colorScheme.surfaceContainerHighest;
      fg = colorScheme.onSurfaceVariant;
    } else {
      label = l10n.eventOutboundInviteStatusPending;
      bg = AppColors.primary.withValues(alpha: 0.14);
      fg = AppColors.primary;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: fg,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
