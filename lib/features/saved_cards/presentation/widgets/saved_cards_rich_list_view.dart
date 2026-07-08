import 'package:cardence/core/widgets/organisms/flippable_person_card.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/saved_card.dart';
import 'saved_card_rich_tile.dart';

/// Kaydedilen kartlar — kart görünümü listesi.
class SavedCardsRichListView extends StatelessWidget {
  const SavedCardsRichListView({
    super.key,
    required this.displayCards,
    required this.onOpenCard,
    this.horizontalPadding = 20,
    this.topPadding = 4,
    this.contentBottomInset = 160,
  });

  final List<SavedCard> displayCards;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;
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
        final heroTag = FlippablePersonCard.heroTagForCardId(card.cardId);

        return SavedCardRichTile(
          card: card,
          accentColor: SavedCardRichTile.accentFor(card, index),
          onDetailTap: () => onOpenCard(card, heroTag: heroTag),
        );
      },
    );
  }
}
