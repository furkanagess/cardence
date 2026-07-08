import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_saved_card_preview.dart';

/// Kaydedilen kartlar yığınının yatay karşılığı: odaklı index öne çıkar,
/// komşular hafif kaydırılmış ve küçültülmüş görünür.
class SavedCardsHorizontalStackView extends StatefulWidget {
  const SavedCardsHorizontalStackView({
    super.key,
    required this.displayCards,
    required this.focusedIndex,
    required this.onFocusedIndexChanged,
    required this.onOpenCard,
    required this.cardWidth,
  });

  static const Duration stackAnimDuration = Duration(milliseconds: 360);
  static const Curve stackAnimCurve = Curves.easeOutCubic;
  static const double cardHorizontalStep = 48;
  static const double focusLeftGap = 16;
  static const double focusRightGap = 16;

  static double revealGap(double cardWidth) =>
      focusLeftGap + (cardWidth - cardHorizontalStep) + focusRightGap;

  static double cardLeftForIndex(
    int index,
    int focusedIndex,
    double cardWidth,
  ) {
    final base = index * cardHorizontalStep;
    if (index < focusedIndex) return base;
    if (index == focusedIndex) return base + focusLeftGap;
    return base + revealGap(cardWidth);
  }

  static double stackContentWidth(
    int length,
    int focusedIndex,
    double cardWidth,
  ) {
    if (length == 0) return 0;
    const extraEndPadding = 24.0;
    var width = 0.0;
    for (var i = 0; i < length; i++) {
      final right =
          cardLeftForIndex(i, focusedIndex, cardWidth) + cardWidth;
      if (right > width) width = right;
    }
    return width + extraEndPadding;
  }

  static double get stackHeight => FlippablePersonCard.fixedHeight + 20;

  final List<SavedCard> displayCards;
  final int focusedIndex;
  final ValueChanged<int> onFocusedIndexChanged;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;
  final double cardWidth;

  @override
  State<SavedCardsHorizontalStackView> createState() =>
      _SavedCardsHorizontalStackViewState();
}

class _SavedCardsHorizontalStackViewState
    extends State<SavedCardsHorizontalStackView> {
  int get _focusedIndex => widget.focusedIndex;

  @override
  void didUpdateWidget(covariant SavedCardsHorizontalStackView oldWidget) {
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
    final cardWidth = widget.cardWidth;
    final contentWidth = SavedCardsHorizontalStackView.stackContentWidth(
      length,
      _focusedIndex,
      cardWidth,
    );

    return SizedBox(
      width: contentWidth,
      height: SavedCardsHorizontalStackView.stackHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final i in _paintOrder(length, _focusedIndex))
            AnimatedPositioned(
              key: ValueKey('h-stack-slot-${widget.displayCards[i].cardId}'),
              duration: SavedCardsHorizontalStackView.stackAnimDuration,
              curve: SavedCardsHorizontalStackView.stackAnimCurve,
              left: SavedCardsHorizontalStackView.cardLeftForIndex(
                i,
                _focusedIndex,
                cardWidth,
              ),
              top: 0,
              width: cardWidth,
              child: _HorizontalStackCardSlot(
                card: widget.displayCards[i],
                isFocused: i == _focusedIndex,
                colorScheme: colorScheme,
                onOpenCard: widget.onOpenCard,
              ),
            ),
        ],
      ),
    );
  }
}

class _HorizontalStackCardSlot extends StatelessWidget {
  const _HorizontalStackCardSlot({
    required this.card,
    required this.isFocused,
    required this.colorScheme,
    required this.onOpenCard,
  });

  final SavedCard card;
  final bool isFocused;
  final ColorScheme colorScheme;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  @override
  Widget build(BuildContext context) {
    final heroTag = FlippablePersonCard.heroTagForCardId(card.cardId);

    return AnimatedScale(
      duration: SavedCardsHorizontalStackView.stackAnimDuration,
      curve: SavedCardsHorizontalStackView.stackAnimCurve,
      alignment: Alignment.centerLeft,
      scale: isFocused ? 1.0 : 0.93,
      child: AnimatedContainer(
        duration: SavedCardsHorizontalStackView.stackAnimDuration,
        curve: SavedCardsHorizontalStackView.stackAnimCurve,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.22),
                    blurRadius: 28,
                    spreadRadius: 1,
                    offset: const Offset(0, 14),
                  ),
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: SavedCardsSavedCardPreview(
          card: card,
          heroTag: heroTag,
          onDetailTap: () => onOpenCard(card, heroTag: heroTag),
        ),
      ),
    );
  }
}
