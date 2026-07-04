import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Etkinlik tarih/konum gibi meta bilgiler için chip.
///
/// Üst bileşenin genişliğini aşmaz; [Wrap] içinde sığmazsa alt satıra geçer,
/// uzun metin chip içinde satır kırar.
class EventGroupMetaChip extends StatelessWidget {
  const EventGroupMetaChip({
    super.key,
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final horizontalPadding = compact ? 10.0 : 12.0;
    final verticalPadding = compact ? 6.0 : 8.0;
    final iconSize = compact ? 14.0 : 16.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fallbackMax = MediaQuery.sizeOf(context).width - 48;
        final maxChipWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : fallbackMax;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxChipWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: isDark ? 0.55 : 0.85,
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isDark
                    ? AppColors.outlineDark.withValues(alpha: 0.35)
                    : AppColors.outlineVariant.withValues(alpha: 0.65),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: iconSize, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: compact ? 12 : null,
                            height: 1.25,
                          ),
                      softWrap: true,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
