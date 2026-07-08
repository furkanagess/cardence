import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/shimmer.dart';

/// Kart / davet sayısı chip satırı iskeleti.
class EventGroupDetailStatChipRowShimmer extends StatelessWidget {
  const EventGroupDetailStatChipRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Shimmer(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ShimmerPlaceholder(
              width: 88,
              height: 38,
              borderRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

/// Yatay kart listesi iskeleti.
class EventGroupDetailCardsSectionShimmer extends StatelessWidget {
  const EventGroupDetailCardsSectionShimmer({super.key});

  static const double _tileWidth = 196;
  static const double _tileHeight = 118;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: SizedBox(
        height: _tileHeight,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, __) => const ShimmerPlaceholder(
            width: _tileWidth,
            height: _tileHeight,
            borderRadius: 14,
          ),
        ),
      ),
    );
  }
}
