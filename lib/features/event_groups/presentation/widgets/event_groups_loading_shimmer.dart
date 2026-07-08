import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/shimmer.dart';
import 'event_group_list_card.dart';
import 'event_groups_horizontal_section.dart';

/// Etkinlik grupları yüklenirken kategorize dikey liste iskeleti.
class EventGroupsLoadingShimmer extends StatelessWidget {
  const EventGroupsLoadingShimmer({super.key});

  static const double _contentBottomInset = 128;

  static const List<int> _sectionCardCounts = [1, 1, 2, 1];

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, _contentBottomInset),
        children: [
          for (var index = 0; index < _sectionCardCounts.length; index++) ...[
            if (index > 0) const SizedBox(height: 20),
            _VerticalSectionShimmer(
              cardCount: _sectionCardCounts[index],
              uppercaseTitle: index == 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _VerticalSectionShimmer extends StatelessWidget {
  const _VerticalSectionShimmer({
    required this.cardCount,
    this.uppercaseTitle = false,
  });

  final int cardCount;
  final bool uppercaseTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ShimmerPlaceholder(
            width: uppercaseTitle ? 88 : 120,
            height: uppercaseTitle ? 14 : 16,
            borderRadius: 8,
          ),
        ),
        for (var index = 0; index < cardCount; index++) ...[
          if (index > 0) const SizedBox(height: EventGroupsSection.cardSpacing),
          const _ListCardShimmer(),
        ],
      ],
    );
  }
}

class _ListCardShimmer extends StatelessWidget {
  const _ListCardShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.85),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: eventGroupListCardCoverHeight,
            child: ShimmerPlaceholder(
              borderRadius: 0,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -eventGroupListCardCoverOverlap),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(eventGroupListCardContentTopRadius),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ShimmerPlaceholder(
                            height: 18,
                            borderRadius: 8,
                          ),
                        ),
                        SizedBox(width: 10),
                        ShimmerPlaceholder(
                          width: 58,
                          height: 24,
                          borderRadius: 999,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ShimmerPlaceholder(
                      width: 180,
                      height: 14,
                      borderRadius: 8,
                    ),
                    SizedBox(height: 6),
                    ShimmerPlaceholder(
                      width: 120,
                      height: 14,
                      borderRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
