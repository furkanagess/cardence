import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event_group.dart';

class EventGroupStatusBadge extends StatelessWidget {
  const EventGroupStatusBadge({
    super.key,
    required this.status,
    this.hero = false,
  });

  final EventGroupStatus status;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = switch (status) {
      EventGroupStatus.ongoing => AppColors.success,
      EventGroupStatus.upcoming => theme.colorScheme.primary,
      EventGroupStatus.ended => theme.colorScheme.onSurfaceVariant,
    };

    if (hero) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDark ? 0.92 : 0.95),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            _statusLabel(context, status),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          _statusLabel(context, status),
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  String _statusLabel(BuildContext context, EventGroupStatus status) {
    return switch (status) {
      EventGroupStatus.upcoming => context.l10n.eventStatusUpcoming,
      EventGroupStatus.ongoing => context.l10n.eventStatusOngoing,
      EventGroupStatus.ended => context.l10n.eventStatusEnded,
    };
  }
}
