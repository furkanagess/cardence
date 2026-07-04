import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/shimmer.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import 'event_group_detail_header.dart';

/// Etkinlik grubu detay ekranı yüklenirken sayfa düzenine uygun iskelet.
class EventGroupDetailLoadingShimmer extends StatelessWidget {
  const EventGroupDetailLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coverHeight = eventGroupDetailCoverHeight(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Shimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: coverHeight,
                child: const ShimmerPlaceholder(
                  height: double.infinity,
                  borderRadius: 0,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: coverHeight - eventGroupDetailCoverOverlap,
                  ),
                  _InfoPanelShimmer(
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
          const EventGroupDetailLinkedCardsHeader(linkedCardCount: 3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, bottomInset),
              child: const Align(
                alignment: Alignment.topCenter,
                child: _LinkedCardShimmer(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoPanelShimmer extends StatelessWidget {
  const _InfoPanelShimmer({
    required this.colorScheme,
    required this.isDark,
  });

  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
      child: const Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ShimmerPlaceholder(
              width: 88,
              height: 28,
              borderRadius: 999,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                ShimmerPlaceholder(
                  width: 168,
                  height: 34,
                  borderRadius: 999,
                ),
                SizedBox(width: 8),
                ShimmerPlaceholder(
                  width: 124,
                  height: 34,
                  borderRadius: 999,
                ),
              ],
            ),
            SizedBox(height: 16),
            ShimmerPlaceholder(
              width: 120,
              height: 16,
              borderRadius: 8,
            ),
            SizedBox(height: 10),
            ShimmerPlaceholder(
              height: 14,
              borderRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkedCardShimmer extends StatelessWidget {
  const _LinkedCardShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: SizedBox(
        height: FlippablePersonCard.fixedHeight,
        width: double.infinity,
        child: const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerPlaceholder(
                    width: 48,
                    height: 48,
                    shape: BoxShape.circle,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.62,
                          alignment: Alignment.centerLeft,
                          child: ShimmerPlaceholder(
                            height: 16,
                            borderRadius: 8,
                          ),
                        ),
                        SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: 0.44,
                          alignment: Alignment.centerLeft,
                          child: ShimmerPlaceholder(
                            height: 12,
                            borderRadius: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
              FractionallySizedBox(
                widthFactor: 0.72,
                alignment: Alignment.centerLeft,
                child: ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
              SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: 0.52,
                alignment: Alignment.centerLeft,
                child: ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
