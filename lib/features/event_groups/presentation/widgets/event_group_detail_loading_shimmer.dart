import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/shimmer.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_card_stack_view.dart';

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

/// Dikey kart yığını iskeleti.
class EventGroupDetailCardsSectionShimmer extends StatelessWidget {
  const EventGroupDetailCardsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final stackHeight = SavedCardsCardStackView.stackContentHeight(1, 0);
    final sectionHeight = stackHeight.clamp(
      FlippablePersonCard.fixedHeight + 24,
      (viewportHeight * 0.52).clamp(300.0, 480.0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Shimmer(
        child: SizedBox(
          height: sectionHeight,
          child: Align(
            alignment: Alignment.topCenter,
            child: ShimmerPlaceholder(
              width: double.infinity,
              height: FlippablePersonCard.fixedHeight,
              borderRadius: 16,
            ),
          ),
        ),
      ),
    );
  }
}
