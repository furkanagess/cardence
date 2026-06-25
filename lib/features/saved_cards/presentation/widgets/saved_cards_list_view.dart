import 'package:flutter/material.dart';

import '../../domain/entities/saved_card.dart';
import 'saved_card_list_tile.dart';
import 'saved_cards_list_header.dart';

/// Kaydedilen kartlar ekranında liste görünümü.
class SavedCardsListView extends StatelessWidget {
  const SavedCardsListView({
    super.key,
    required this.displayCards,
    required this.onCardTap,
    this.horizontalPadding = 20,
    this.topPadding = 4,
    this.contentBottomInset = 128,
  });

  final List<SavedCard> displayCards;
  final ValueChanged<SavedCard> onCardTap;
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
      itemCount: displayCards.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return SavedCardsListHeader(count: displayCards.length);
        }

        final card = displayCards[index - 1];
        return SavedCardListTile(
          card: card,
          onTap: () => onCardTap(card),
        );
      },
    );
  }
}
