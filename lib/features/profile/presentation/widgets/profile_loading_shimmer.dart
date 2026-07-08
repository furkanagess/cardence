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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: ShimmerPlaceholder(width: 180, height: 32, borderRadius: 999),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerPlaceholder(
              height: cardHeight,
              borderRadius: 16,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ShimmerPlaceholder(height: 54, borderRadius: 14),
                SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ShimmerPlaceholder(height: 104, borderRadius: 14),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ShimmerPlaceholder(height: 104, borderRadius: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerPlaceholder(
              height: 220,
              borderRadius: 20,
            ),
          ),
        ],
      ),
    );
  }
}
