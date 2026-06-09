import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/shimmer.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';

/// Kaydedilen kartlar yüklenirken kartvizit boyutunda liste iskeleti.
class SavedCardsLoadingShimmer extends StatelessWidget {
  const SavedCardsLoadingShimmer({super.key});

  static const int _itemCount = 3;
  static const double _cardGap = 16;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 128),
        itemCount: _itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: _cardGap),
        itemBuilder: (context, index) => _SavedCardShimmer(index: index),
      ),
    );
  }
}

class _SavedCardShimmer extends StatelessWidget {
  const _SavedCardShimmer({required this.index});

  final int index;

  double get _line1WidthFactor => switch (index % 3) {
        0 => 0.72,
        1 => 0.64,
        _ => 0.68,
      };

  double get _line2WidthFactor => switch (index % 3) {
        0 => 0.52,
        1 => 0.46,
        _ => 0.5,
      };

  double get _line3WidthFactor => switch (index % 3) {
        0 => 0.38,
        1 => 0.42,
        _ => 0.36,
      };

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ShimmerPlaceholder(
                    width: 48,
                    height: 48,
                    shape: BoxShape.circle,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 0.62,
                          alignment: Alignment.centerLeft,
                          child: const ShimmerPlaceholder(
                            height: 16,
                            borderRadius: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FractionallySizedBox(
                          widthFactor: 0.44,
                          alignment: Alignment.centerLeft,
                          child: const ShimmerPlaceholder(
                            height: 12,
                            borderRadius: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const ShimmerPlaceholder(
                    width: 28,
                    height: 28,
                    borderRadius: 8,
                  ),
                ],
              ),
              const Spacer(),
              FractionallySizedBox(
                widthFactor: _line1WidthFactor,
                alignment: Alignment.centerLeft,
                child: const ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: _line2WidthFactor,
                alignment: Alignment.centerLeft,
                child: const ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
              const SizedBox(height: 10),
              FractionallySizedBox(
                widthFactor: _line3WidthFactor,
                alignment: Alignment.centerLeft,
                child: const ShimmerPlaceholder(height: 12, borderRadius: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
