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
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? AppColors.outlineDark.withValues(alpha: 0.35)
                    : AppColors.outlineVariant.withValues(alpha: 0.75),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ShimmerPlaceholder(
                  height: 132,
                  borderRadius: 0,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FractionallySizedBox(
                        widthFactor: index.isEven ? 0.72 : 0.58,
                        alignment: Alignment.centerLeft,
                        child: const ShimmerPlaceholder(
                          height: 18,
                          borderRadius: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ShimmerPlaceholder(
                            width: index.isEven ? 148 : 128,
                            height: 28,
                            borderRadius: 999,
                          ),
                          const SizedBox(width: 8),
                          ShimmerPlaceholder(
                            width: index.isEven ? 112 : 96,
                            height: 28,
                            borderRadius: 999,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      FractionallySizedBox(
                        widthFactor: 0.42,
                        alignment: Alignment.centerLeft,
                        child: const ShimmerPlaceholder(
                          height: 14,
                          borderRadius: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
