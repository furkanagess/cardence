import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/shimmer.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';

/// Kartlarım (profil) sekmesi yüklenirken iskelet görünüm.
class ProfileLoadingShimmer extends StatelessWidget {
  const ProfileLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom + 96;
    final cardWidth = MediaQuery.sizeOf(context).width - 40;
    final cardHeight = cardWidth / FlippablePersonCard.cardAspectRatio;

    return Shimmer(
      child: ListView(
        padding: EdgeInsets.fromLTRB(0, 8, 0, 32 + bottomInset),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FractionallySizedBox(
              widthFactor: 0.88,
              alignment: Alignment.centerLeft,
              child: const ShimmerPlaceholder(height: 14, borderRadius: 8),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerPlaceholder(
              height: cardHeight,
              borderRadius: 16,
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerPlaceholder(height: 52, borderRadius: 12),
          ),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerPlaceholder(
              width: 140,
              height: 14,
              borderRadius: 8,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: const [
                Expanded(
                  child: ShimmerPlaceholder(height: 92, borderRadius: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ShimmerPlaceholder(height: 92, borderRadius: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerPlaceholder(height: 76, borderRadius: 16),
          ),
        ],
      ),
    );
  }
}
