import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/shimmer.dart';

/// Etkinlik grupları listesi yüklenirken iskelet görünüm.
class EventGroupsLoadingShimmer extends StatelessWidget {
  const EventGroupsLoadingShimmer({super.key});

  static const int _itemCount = 5;
  static const double _contentBottomInset = 128;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, _contentBottomInset),
        itemCount: _itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? AppColors.outlineDark.withValues(alpha: 0.25)
                    : AppColors.outlineVariant.withValues(alpha: 0.55),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  ShimmerPlaceholder(
                    width: 44,
                    height: 44,
                    borderRadius: 10,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: index.isEven ? 0.72 : 0.58,
                          alignment: Alignment.centerLeft,
                          child: const ShimmerPlaceholder(
                            height: 16,
                            borderRadius: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: index.isEven ? 0.48 : 0.42,
                          alignment: Alignment.centerLeft,
                          child: const ShimmerPlaceholder(
                            height: 12,
                            borderRadius: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ShimmerPlaceholder(
                    width: 24,
                    height: 24,
                    borderRadius: 8,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
