import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/event_group_invitation.dart';

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
                        l10n.eventInvitationInvitedSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(
                      alpha: isDark ? 0.45 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _InvitationResponseActions(
              acceptLabel: l10n.eventInvitationAccept,
              rejectLabel: l10n.eventInvitationReject,
              isResponding: isResponding,
              onAccept: onAccept,
              onReject: onReject,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationResponseActions extends StatelessWidget {
  const _InvitationResponseActions({
    required this.acceptLabel,
    required this.rejectLabel,
    required this.isResponding,
    required this.onAccept,
    required this.onReject,
  });

  final String acceptLabel;
  final String rejectLabel;
  final bool isResponding;
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
              backgroundColor: AppColors.primary,
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
