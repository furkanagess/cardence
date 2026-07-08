import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/media/media_image_size.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_list_display_formatter.dart';

/// Liste kartı üst kapak yüksekliği.
const double eventGroupListCardCoverHeight = 100;

/// Kapak ile içerik paneli arasındaki bindirme.
const double eventGroupListCardCoverOverlap = 14;

/// İçerik paneli üst köşe yarıçapı.
const double eventGroupListCardContentTopRadius = 20;

/// Etkinlik grupları liste ekranında dikey bölüm kartı.
class EventGroupListCard extends StatelessWidget {
  const EventGroupListCard({
    super.key,
    required this.group,
    required this.linkedCardCount,
    required this.onTap,
  });

  final EventGroup group;
  final int linkedCardCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = context.l10n;
    final city = EventGroupListDisplayFormatter.primaryCityFromLocation(
      group.location,
    );
    final cardCountLabel =
        EventGroupListDisplayFormatter.linkedCardCountLabel(l10n, linkedCardCount);
    final highlightBadge = group.status == EventGroupStatus.ongoing;

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
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _EventGroupListCardCover(group: group),
            Transform.translate(
              offset: const Offset(0, -eventGroupListCardCoverOverlap),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(eventGroupListCardContentTopRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.08 : 0.05,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _CardCountBadge(
                            label: cardCountLabel,
                            highlighted: highlightBadge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ..._buildMetaRows(
                        context,
                        city: city,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetaRows(
    BuildContext context, {
    required String? city,
  }) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final mutedColor = Theme.of(context).colorScheme.onSurfaceVariant;

    return switch (group.status) {
      EventGroupStatus.ongoing => [
          if (city != null)
            _MetaRow(
              icon: Icons.location_on_outlined,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: city,
                      style: textTheme.bodyMedium?.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: '  •  ${EventGroupListDisplayFormatter.ongoingTimingLabel(l10n)}',
                      style: textTheme.bodyMedium?.copyWith(
                        color: mutedColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            _MetaRow(
              icon: Icons.calendar_today_outlined,
              label: EventGroupListDisplayFormatter.ongoingTimingLabel(l10n),
              color: mutedColor,
            ),
        ],
      EventGroupStatus.upcoming => [
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: EventGroupListDisplayFormatter.formatUpcomingDateRange(
              l10n,
              group.startAt,
              group.endAt,
            ),
            color: mutedColor,
          ),
          if (city != null) ...[
            const SizedBox(height: 6),
            _MetaRow(
              icon: Icons.map_outlined,
              label: city,
              color: mutedColor,
            ),
          ],
        ],
      EventGroupStatus.ended => [
          _MetaRow(
            icon: Icons.calendar_today_outlined,
            label: EventGroupListDisplayFormatter.endedSummaryLabel(
              l10n,
              group.endAt ?? group.startAt,
            ),
            color: mutedColor,
          ),
          if (city != null) ...[
            const SizedBox(height: 6),
            _MetaRow(
              icon: Icons.location_on_outlined,
              label: city,
              color: mutedColor,
            ),
          ],
        ],
    };
  }
}

class _EventGroupListCardCover extends StatelessWidget {
  const _EventGroupListCardCover({required this.group});

  final EventGroup group;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photoUrl = group.photoUrl?.trim();
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return SizedBox(
      height: eventGroupListCardCoverHeight,
      width: double.infinity,
      child: hasPhoto
          ? AuthenticatedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              height: eventGroupListCardCoverHeight,
              displaySize: MediaImageSize.small,
              errorBuilder: (_) => _PlaceholderCover(isDark: isDark),
              loadingBuilder: (_) => _PlaceholderCover(isDark: isDark),
            )
          : _PlaceholderCover(isDark: isDark),
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
                  AppColors.textPrimary.withValues(alpha: 0.85),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.55),
                  AppColors.textPrimary.withValues(alpha: 0.78),
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 28,
          color: AppColors.textOnPrimary.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _CardCountBadge extends StatelessWidget {
  const _CardCountBadge({
    required this.label,
    required this.highlighted,
  });

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = highlighted
        ? AppColors.primaryContainer.withValues(alpha: isDark ? 0.55 : 1)
        : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant);
    final foreground = highlighted
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    this.label,
    this.child,
    this.color,
  });

  final IconData icon;
  final String? label;
  final Widget? child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 16, color: resolvedColor.withValues(alpha: 0.85)),
        const SizedBox(width: 8),
        Expanded(
          child: child ??
              Text(
                label ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: resolvedColor,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
              ),
        ),
      ],
    );
  }
}
