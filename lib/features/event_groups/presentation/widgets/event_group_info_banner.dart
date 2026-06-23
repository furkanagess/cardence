import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_meta_formatter.dart';

class EventGroupInfoBanner extends StatelessWidget {
  const EventGroupInfoBanner({super.key, required this.group});

  final EventGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateText = EventGroupMetaFormatter.formatDate(group.eventDate);
    final location = group.location?.trim();
    final hasPhoto = group.photoUrl?.trim().isNotEmpty == true;
    final hasMeta =
        (dateText != null && dateText.isNotEmpty) ||
        (location != null && location.isNotEmpty);

    if (!hasPhoto && !hasMeta) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest.withValues(
            alpha: isDark ? 0.55 : 0.85,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.outlineDark.withValues(alpha: 0.35)
                : AppColors.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasPhoto) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      group.photoUrl!.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ColoredBox(
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
                if (hasMeta) const SizedBox(height: 14),
              ],
              if (dateText != null && dateText.isNotEmpty)
                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: 'Tarih',
                  value: dateText,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
              if (dateText != null &&
                  dateText.isNotEmpty &&
                  location != null &&
                  location.isNotEmpty)
                const SizedBox(height: 10),
              if (location != null && location.isNotEmpty)
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Konum',
                  value: location,
                  textTheme: textTheme,
                  colorScheme: colorScheme,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textTheme,
    required this.colorScheme,
  });

  final IconData icon;
  final String label;
  final String value;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
