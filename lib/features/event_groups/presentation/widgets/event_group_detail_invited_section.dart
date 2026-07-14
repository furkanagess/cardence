import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../domain/entities/event_group_outbound_invitation.dart';

/// Etkinlik detayında gönderilmiş davetler listesi.
class EventGroupDetailInvitedSection extends StatelessWidget {
  const EventGroupDetailInvitedSection({
    super.key,
    required this.invitations,
    this.isLoading = false,
  });

  final List<EventGroupOutboundInvitation> invitations;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.eventOutboundInvitesSectionTitle,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (invitations.isEmpty)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: isDark ? 0.45 : 0.85,
                  ),
                ),
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: isDark ? 0.22 : 0.4,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Text(
                  context.l10n.eventOutboundInvitesEmpty,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            )
          else
            ...[
              for (var i = 0; i < invitations.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _InviteeTile(invitation: invitations[i]),
              ],
            ],
        ],
      ),
    );
  }
}

class _InviteeTile extends StatelessWidget {
  const _InviteeTile({required this.invitation});

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
            _StatusChip(invitation: invitation),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.invitation});

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
