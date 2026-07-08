import 'package:flutter/material.dart';

import '../../domain/entities/saved_card.dart';
import 'saved_card_list_tile.dart';

/// Kaydedilen kartlar ekranında kompakt liste görünümü.
class SavedCardsListView extends StatelessWidget {
  const SavedCardsListView({
    super.key,
    required this.displayCards,
    required this.onDetailTap,
    this.horizontalPadding = 20,
    this.topPadding = 4,
    this.contentBottomInset = 160,
  });

  final List<SavedCard> displayCards;
  final ValueChanged<SavedCard> onDetailTap;
  final double horizontalPadding;
  final double topPadding;
  final double contentBottomInset;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        contentBottomInset,
      ),
      itemCount: displayCards.length,
      itemBuilder: (context, index) {
        final card = displayCards[index];
        return SavedCardListTile(
          card: card,
          onDetailTap: () => onDetailTap(card),
        );
      },
    );
  }
}
