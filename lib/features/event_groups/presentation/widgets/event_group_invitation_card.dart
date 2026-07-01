import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/event_group_invitation.dart';
import '../helpers/event_group_meta_formatter.dart';
import 'event_group_cover_thumbnail.dart';

class EventGroupInvitationCard extends StatelessWidget {
  const EventGroupInvitationCard({
    super.key,
    required this.invitation,
    required this.onAccept,
    required this.onReject,
    this.isResponding = false,
  });

  final EventGroupInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final bool isResponding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final dateText = EventGroupMetaFormatter.formatRange(
      invitation.startAt,
      invitation.endAt,
    );
    final location = invitation.location?.trim();
    final cardLabel = invitation.cardDisplayName?.trim();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(
          alpha: isDark ? 0.22 : 0.35,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventGroupCoverThumbnail(
                  photoUrl: invitation.photoUrl,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.eventInvitationTitle,
                        style: textTheme.titleSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.eventInvitationMessage(
                          invitation.inviterName,
                          invitation.eventName,
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (cardLabel != null && cardLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.eventInvitationCardLabel(cardLabel),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (dateText.isNotEmpty ||
                (location != null && location.isNotEmpty)) ...[
              const SizedBox(height: 12),
              if (dateText.isNotEmpty)
                _MetaRow(
                  icon: Icons.calendar_month_outlined,
                  text: dateText,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
              if (dateText.isNotEmpty &&
                  location != null &&
                  location.isNotEmpty)
                const SizedBox(height: 6),
              if (location != null && location.isNotEmpty)
                _MetaRow(
                  icon: Icons.location_on_outlined,
                  text: location,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: CustomButton.outlined(
                    label: l10n.eventInvitationReject,
                    onPressed: isResponding ? null : onReject,
                    enabled: !isResponding,
                    fullWidth: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    label: l10n.eventInvitationAccept,
                    onPressed: isResponding ? null : onAccept,
                    enabled: !isResponding,
                    isLoading: isResponding,
                    fullWidth: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.text,
    required this.colorScheme,
    required this.textTheme,
  });

  final IconData icon;
  final String text;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
