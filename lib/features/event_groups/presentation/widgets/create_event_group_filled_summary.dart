import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../helpers/event_group_meta_formatter.dart';
import 'event_group_cover_thumbnail.dart';

/// Oluşturma akışında doldurulmuş alanların özet kartı.
class CreateEventGroupFilledSummary extends StatelessWidget {
  const CreateEventGroupFilledSummary({
    super.key,
    required this.name,
    required this.location,
    required this.startAt,
    this.endAt,
    this.photoFilePath,
  });

  final String name;
  final String? location;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? photoFilePath;

  bool get _hasContent {
    if (name.trim().isNotEmpty) return true;
    if (location != null && location!.trim().isNotEmpty) return true;
    if (startAt != null) return true;
    if (photoFilePath != null && photoFilePath!.trim().isNotEmpty) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasContent) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final trimmedName = name.trim();
    final trimmedLocation = location?.trim();
    final scheduleText = startAt == null
        ? null
        : EventGroupMetaFormatter.formatRange(startAt!, endAt);
    final hasPhoto = photoFilePath != null && photoFilePath!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest.withValues(
            alpha: isDark ? 0.55 : 0.85,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppColors.outlineDark.withValues(alpha: 0.35)
                : AppColors.outlineVariant.withValues(alpha: 0.75),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasPhoto) ...[
                EventGroupCoverThumbnail(
                  localFilePath: photoFilePath,
                  size: 40,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trimmedName.isNotEmpty)
                      Text(
                        trimmedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    if (trimmedLocation != null &&
                        trimmedLocation.isNotEmpty) ...[
                      if (trimmedName.isNotEmpty) const SizedBox(height: 4),
                      _SummaryLine(
                        icon: Icons.location_on_outlined,
                        text: trimmedLocation,
                      ),
                    ],
                    if (scheduleText != null) ...[
                      if (trimmedName.isNotEmpty ||
                          (trimmedLocation != null &&
                              trimmedLocation.isNotEmpty))
                        const SizedBox(height: 4),
                      _SummaryLine(
                        icon: Icons.event_outlined,
                        text: scheduleText,
                      ),
                    ],
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
