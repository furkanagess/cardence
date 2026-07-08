import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/shimmer.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_horizontal_carousel.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_horizontal_stack_view.dart';

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

/// Yatay kart şeridi iskeleti.
class EventGroupDetailCardsSectionShimmer extends StatelessWidget {
  const EventGroupDetailCardsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final contentWidth = MediaQuery.sizeOf(context).width;
    final cardWidth = SavedCardsHorizontalCarousel.resolveCardWidth(contentWidth);
    final height = SavedCardsHorizontalCarousel.sectionHeight(cardWidth);

    return Shimmer(
      child: SizedBox(
        height: height,
        child: Center(
          child: ShimmerPlaceholder(
            width: cardWidth,
            height: SavedCardsHorizontalStackView.stackHeight,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}
