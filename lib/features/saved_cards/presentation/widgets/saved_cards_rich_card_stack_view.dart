import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_card_rich_tile.dart';

class SavedCardsRichCardStackView extends StatefulWidget {
  const SavedCardsRichCardStackView({
    super.key,
    required this.displayCards,
    required this.focusedIndex,
    required this.onFocusedIndexChanged,
    required this.onOpenCard,
  });

  static const Duration stackAnimDuration = Duration(milliseconds: 360);
  static const Curve stackAnimCurve = Curves.easeOutCubic;
  static const double cardVerticalStep = 44;

  static const double focusTopGap = 10;
  static const double focusBottomGap = 10;

  static double revealGapFor(double tileHeight) =>
      focusTopGap + (tileHeight - cardVerticalStep) + focusBottomGap;

  static double cardTopForIndex(
    int index,
    int focusedIndex,
    double tileHeight,
  ) {
    final revealGap = revealGapFor(tileHeight);
    final base = index * cardVerticalStep;
    if (index < focusedIndex) return base;
    if (index == focusedIndex) return base + focusTopGap;
    return base + revealGap;
  }

  static double stackContentHeight(
    int length,
    int focusedIndex,
    double tileHeight,
  ) {
    if (length == 0) return 0;
    const extraBottomPadding = 24.0;
    var height = 0.0;
    for (var i = 0; i < length; i++) {
      final bottom = cardTopForIndex(i, focusedIndex, tileHeight) + tileHeight;
      if (bottom > height) height = bottom;
    }
    return height + extraBottomPadding;
  }

  final List<SavedCard> displayCards;
  final int focusedIndex;
  final ValueChanged<int> onFocusedIndexChanged;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  @override
  State<SavedCardsRichCardStackView> createState() =>
      _SavedCardsRichCardStackViewState();
}

class _SavedCardsRichCardStackViewState
    extends State<SavedCardsRichCardStackView> {
  int get _focusedIndex => widget.focusedIndex;

  @override
  void didUpdateWidget(covariant SavedCardsRichCardStackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusedIndex >= widget.displayCards.length &&
        widget.displayCards.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        widget.onFocusedIndexChanged(widget.displayCards.length - 1);
      });
    }
  }

  List<int> _paintOrder(int length, int focused) {
    final order = <int>[];
    for (var i = 0; i < length; i++) {
      if (i != focused) order.add(i);
    }
    if (length > 0) order.add(focused);
    return order;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final length = widget.displayCards.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileHeight =
            SavedCardRichTile.stackTileHeightFor(constraints.maxWidth);
        final cardsHeight = SavedCardsRichCardStackView.stackContentHeight(
          length,
          _focusedIndex,
          tileHeight,
        );

        return SizedBox(
          height: cardsHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final i in _paintOrder(length, _focusedIndex))
                AnimatedPositioned(
                  key: ValueKey(
                    'rich-stack-slot-${widget.displayCards[i].cardId}',
                  ),
                  duration: SavedCardsRichCardStackView.stackAnimDuration,
                  curve: SavedCardsRichCardStackView.stackAnimCurve,
                  top: SavedCardsRichCardStackView.cardTopForIndex(
                    i,
                    _focusedIndex,
                    tileHeight,
                  ),
                  left: 0,
                  right: 0,
                  child: _RichStackCardSlot(
                    card: widget.displayCards[i],
                    cardIndex: i,
                    isFocused: i == _focusedIndex,
                    colorScheme: colorScheme,
                    onOpenCard: widget.onOpenCard,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RichStackCardSlot extends StatelessWidget {
  const _RichStackCardSlot({
    required this.card,
    required this.cardIndex,
    required this.isFocused,
    required this.colorScheme,
    required this.onOpenCard,
  });

  final SavedCard card;
  final int cardIndex;
  final bool isFocused;
  final ColorScheme colorScheme;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  @override
  Widget build(BuildContext context) {
    final heroTag = FlippablePersonCard.heroTagForCardId(card.cardId);

    return AnimatedScale(
      duration: SavedCardsRichCardStackView.stackAnimDuration,
      curve: SavedCardsRichCardStackView.stackAnimCurve,
      alignment: Alignment.topCenter,
      scale: isFocused ? 1.0 : 0.96,
      child: AnimatedOpacity(
        duration: SavedCardsRichCardStackView.stackAnimDuration,
        curve: SavedCardsRichCardStackView.stackAnimCurve,
        opacity: isFocused ? 1 : 0.9,
        child: SavedCardRichTile(
          card: card,
          accentColor: SavedCardRichTile.accentFor(card, cardIndex),
          trailingGap: false,
          onDetailTap: heroTag == null
              ? null
              : () => onOpenCard(card, heroTag: heroTag),
        ),
      ),
    );
  }
}
