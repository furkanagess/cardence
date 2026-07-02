import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/event_group_invitation.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_invitation_formatter.dart';
import '../helpers/event_group_meta_formatter.dart';

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
    final eventStatus = EventGroupInvitationFormatter.eventStatus(
      invitation.startAt,
      invitation.endAt,
    );
    final timeBadgeLabel =
        EventGroupInvitationFormatter.eventStartRemainingLabel(
      l10n,
      invitation.startAt,
      invitation.endAt,
    );
    final hasPhoto = invitation.photoUrl?.trim().isNotEmpty == true;
    final inviterInitial = _initialFromName(invitation.inviterName);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.14 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ColoredBox(
          color: colorScheme.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CoverBanner(
                eventName: invitation.eventName,
                photoUrl: invitation.photoUrl,
                hasPhoto: hasPhoto,
                isDark: isDark,
                startAt: invitation.startAt,
                timeLabel: timeBadgeLabel,
                eventStatus: eventStatus,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary,
                                colorScheme.primary.withValues(alpha: 0.75),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: Center(
                              child: Text(
                                inviterInitial,
                                style: textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.eventInvitationInvitedBy(
                                  invitation.inviterName,
                                ),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                l10n.eventInvitationTitle(invitation.eventName),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (dateText.isNotEmpty ||
                        (location != null && location.isNotEmpty)) ...[
                      const SizedBox(height: 12),
                      if (dateText.isNotEmpty)
                        _MetaLine(
                          icon: Icons.calendar_month_outlined,
                          text: dateText,
                          colorScheme: colorScheme,
                        ),
                      if (dateText.isNotEmpty &&
                          location != null &&
                          location.isNotEmpty)
                        const SizedBox(height: 6),
                      if (location != null && location.isNotEmpty)
                        _MetaLine(
                          icon: Icons.location_on_outlined,
                          text: location,
                          colorScheme: colorScheme,
                        ),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Divider(
                        height: 1,
                        color: isDark
                            ? AppColors.outlineDark.withValues(alpha: 0.35)
                            : AppColors.outlineVariant.withValues(alpha: 0.65),
                      ),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }

  static String _initialFromName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

class _CoverBanner extends StatelessWidget {
  const _CoverBanner({
    required this.eventName,
    required this.photoUrl,
    required this.hasPhoto,
    required this.isDark,
    required this.startAt,
    required this.timeLabel,
    required this.eventStatus,
  });

  final String eventName;
  final String? photoUrl;
  final bool hasPhoto;
  final bool isDark;
  final DateTime startAt;
  final String timeLabel;
  final EventGroupStatus eventStatus;

  Color _badgeColor(ColorScheme colorScheme) {
    return switch (eventStatus) {
      EventGroupStatus.ongoing => AppColors.success,
      EventGroupStatus.ended => colorScheme.onSurfaceVariant,
      EventGroupStatus.upcoming =>
        EventGroupInvitationFormatter.daysUntilEventStart(startAt) <= 1
            ? AppColors.warning
            : AppColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final accentColor = _badgeColor(colorScheme);

    return SizedBox(
      height: 128,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasPhoto)
            AuthenticatedNetworkImage(
              imageUrl: photoUrl!.trim(),
              fit: BoxFit.cover,
              errorBuilder: (_) => _PlaceholderCover(isDark: isDark),
            )
          else
            _PlaceholderCover(isDark: isDark),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.textPrimary.withValues(alpha: isDark ? 0.08 : 0.04),
                  AppColors.textPrimary.withValues(alpha: isDark ? 0.72 : 0.58),
                ],
              ),
            ),
          ),
          Positioned(
            left: 14,
            top: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Text(
              eventName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w800,
                height: 1.15,
                shadows: [
                  Shadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.45),
                  AppColors.primary.withValues(alpha: 0.18),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.28),
                  AppColors.primary.withValues(alpha: 0.08),
                ],
        ),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Icon(
            Icons.event_rounded,
            size: 48,
            color: AppColors.textOnPrimary.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({
    required this.icon,
    required this.text,
    required this.colorScheme,
  });

  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
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
    required this.onAccept,
    required this.onReject,
  });

  final String acceptLabel;
  final String rejectLabel;
  final bool isResponding;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  static const _actionButtonHeight = 44.0;

  @override
  Widget build(BuildContext context) {
    const buttonPadding = EdgeInsets.symmetric(horizontal: 12);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              minimumSize: const Size(0, _actionButtonHeight),
              maximumSize: const Size(double.infinity, _actionButtonHeight),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: buttonPadding,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: CustomButton(
            label: acceptLabel,
            icon: Icons.check_rounded,
            height: _actionButtonHeight,
            onPressed: isResponding ? null : onAccept,
            enabled: !isResponding,
            isLoading: isResponding,
            fullWidth: true,
            visualDensity: VisualDensity.compact,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
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
