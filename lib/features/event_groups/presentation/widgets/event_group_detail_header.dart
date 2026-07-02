import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_meta_formatter.dart';
import 'event_group_meta_chip.dart';
import 'event_group_status_badge.dart';

/// Detay ekranı kapak yüksekliği (16:9).
double eventGroupDetailCoverHeight(BuildContext context) {
  return MediaQuery.sizeOf(context).width * 9 / 16;
}

/// Detay ekranında kaydırılabilir panel ile kapak arasındaki bindirme.
const double eventGroupDetailCoverOverlap = 24;

/// Etkinlik detay kapak görseli; scroll sırasında arka planda sabit kalır.
class EventGroupDetailCover extends StatelessWidget {
  const EventGroupDetailCover({
    super.key,
    required this.group,
  });

  final EventGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = group.photoUrl?.trim().isNotEmpty == true;

    return SizedBox(
      height: eventGroupDetailCoverHeight(context),
      width: double.infinity,
      child: _CoverSection(
        hasPhoto: hasPhoto,
        photoUrl: group.photoUrl,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
    );
  }
}

/// Kapak altındaki bilgi paneli (durum, tarih, konum, açıklama).
class EventGroupDetailInfoSection extends StatelessWidget {
  const EventGroupDetailInfoSection({
    super.key,
    required this.group,
    this.linkedCardCount,
  });

  final EventGroup group;
  final int? linkedCardCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateText = EventGroupMetaFormatter.formatRange(
      group.startAt,
      group.endAt,
    );
    final location = group.location?.trim();
    final description = group.description?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.06 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EventGroupStatusBadge(status: group.status),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (dateText.isNotEmpty)
                      EventGroupMetaChip(
                        icon: Icons.calendar_month_outlined,
                        label: dateText,
                      ),
                    if (location != null && location.isNotEmpty)
                      EventGroupMetaChip(
                        icon: Icons.location_on_outlined,
                        label: location,
                      ),
                  ],
                ),
                if (description != null && description.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.eventAboutSection,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (linkedCardCount != null) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.eventLinkedCardsSection(linkedCardCount!),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CoverSection extends StatelessWidget {
  const _CoverSection({
    required this.hasPhoto,
    this.photoUrl,
    required this.colorScheme,
    required this.isDark,
  });

  final bool hasPhoto;
  final String? photoUrl;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (hasPhoto) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AuthenticatedNetworkImage(
            imageUrl: photoUrl!.trim(),
            fit: BoxFit.cover,
            errorBuilder: (_) => _PlaceholderCover(colorScheme: colorScheme),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppColors.textPrimary.withValues(alpha: isDark ? 0.55 : 0.35),
                ],
              ),
            ),
          ),
        ],
      );
    }

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
          size: 56,
          color: colorScheme.primary.withValues(alpha: 0.45),
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.event_rounded,
        size: 48,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
