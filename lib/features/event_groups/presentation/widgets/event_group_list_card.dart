import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_meta_formatter.dart';
import 'event_group_meta_chip.dart';
import 'event_group_status_badge.dart';

/// Etkinlik grupları listesinde detay ekranına uyumlu kart.
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEnded = group.status == EventGroupStatus.ended;
    final dateText = EventGroupMetaFormatter.formatRange(
      group.startAt,
      group.endAt,
    );
    final location = group.location?.trim();
    final description = group.description?.trim();
    final cardCountLabel = linkedCardCount == 0
        ? AppL10n.noCardsInGroup(context.l10n)
        : AppL10n.savedCardsCount(context.l10n, linkedCardCount);

    return Material(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: isEnded ? 0.88 : 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CoverStrip(
                photoUrl: group.photoUrl,
                status: group.status,
                isDark: isDark,
                colorScheme: colorScheme,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (dateText.isNotEmpty ||
                        (location != null && location.isNotEmpty)) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (dateText.isNotEmpty)
                            EventGroupMetaChip(
                              icon: Icons.calendar_month_outlined,
                              label: dateText,
                              compact: true,
                            ),
                          if (location != null && location.isNotEmpty)
                            EventGroupMetaChip(
                              icon: Icons.location_on_outlined,
                              label: location,
                              compact: true,
                            ),
                        ],
                      ),
                    ],
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            cardCountLabel,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
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
}

class _CoverStrip extends StatelessWidget {
  const _CoverStrip({
    required this.photoUrl,
    required this.status,
    required this.isDark,
    required this.colorScheme,
  });

  final String? photoUrl;
  final EventGroupStatus status;
  final bool isDark;
  final ColorScheme colorScheme;

  static const double _height = 132;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl?.trim().isNotEmpty == true;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasPhoto)
            AuthenticatedNetworkImage(
              imageUrl: photoUrl!.trim(),
              fit: BoxFit.cover,
              errorBuilder: (_) => _GradientCover(
                isDark: isDark,
                colorScheme: colorScheme,
              ),
            )
          else
            _GradientCover(isDark: isDark, colorScheme: colorScheme),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.textPrimary.withValues(alpha: isDark ? 0.18 : 0.08),
                  AppColors.textPrimary.withValues(alpha: isDark ? 0.55 : 0.35),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: EventGroupStatusBadge(status: status),
          ),
        ],
      ),
    );
  }
}

class _GradientCover extends StatelessWidget {
  const _GradientCover({
    required this.isDark,
    required this.colorScheme,
  });

  final bool isDark;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.surfaceVariantDark,
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.surfaceVariant,
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 44,
          color: colorScheme.primary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}
