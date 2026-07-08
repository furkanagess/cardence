import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_saved_card_preview.dart';

class SavedCardsCardStackView extends StatefulWidget {
  const SavedCardsCardStackView({
    super.key,
    required this.displayCards,
    required this.focusedIndex,
    required this.onFocusedIndexChanged,
    required this.onOpenCard,
  });

  static const Duration stackAnimDuration = Duration(milliseconds: 360);
  static const Curve stackAnimCurve = Curves.easeOutCubic;
  static const double cardVerticalStep = 64;

  /// Odaklı kartın üstündeki ve altındaki yığından ayrılma boşluğu.
  static const double focusTopGap = 16;
  static const double focusBottomGap = 16;

  /// Odaklı kartın tamamen görünmesi için alttaki kartların itildiği mesafe.
  static double get revealGap =>
      focusTopGap +
      (FlippablePersonCard.fixedHeight - cardVerticalStep) +
      focusBottomGap;

  /// Kartın yığın içindeki üst konumu (scroll ortalama için).
  static double cardTopForIndex(int index, int focusedIndex) {
    final base = index * cardVerticalStep;
    if (index < focusedIndex) return base;
    if (index == focusedIndex) return base + focusTopGap;
    return base + revealGap;
  }

  /// Yığın içeriğinin toplam yüksekliği.
  static double stackContentHeight(int length, int focusedIndex) {
    if (length == 0) return 0;
    const extraBottomPadding = 24.0;
    var height = 0.0;
    for (var i = 0; i < length; i++) {
      final bottom =
          cardTopForIndex(i, focusedIndex) + FlippablePersonCard.fixedHeight;
      if (bottom > height) height = bottom;
    }
    return height + extraBottomPadding;
  }

  final List<SavedCard> displayCards;
  final int focusedIndex;
  final ValueChanged<int> onFocusedIndexChanged;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  @override
  State<SavedCardsCardStackView> createState() =>
      _SavedCardsCardStackViewState();
}

class _SavedCardsCardStackViewState extends State<SavedCardsCardStackView> {
  int get _focusedIndex => widget.focusedIndex;

  @override
  void didUpdateWidget(covariant SavedCardsCardStackView oldWidget) {
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

  /// Kartın dikey konumu: odaklı kart ve sonrası, onu açığa çıkarmak için itilir.
  double _cardTopFor(int index, int focused) =>
      SavedCardsCardStackView.cardTopForIndex(index, focused);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final length = widget.displayCards.length;
    final cardsHeight =
        SavedCardsCardStackView.stackContentHeight(length, _focusedIndex);

    return SizedBox(
      height: cardsHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (final i in _paintOrder(length, _focusedIndex))
            AnimatedPositioned(
              key: ValueKey('stack-slot-${widget.displayCards[i].cardId}'),
              duration: SavedCardsCardStackView.stackAnimDuration,
              curve: SavedCardsCardStackView.stackAnimCurve,
              top: _cardTopFor(i, _focusedIndex),
              left: 0,
              right: 0,
              child: _StackCardSlot(
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

class _StackCardSlot extends StatelessWidget {
  const _StackCardSlot({
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
      duration: SavedCardsCardStackView.stackAnimDuration,
      curve: SavedCardsCardStackView.stackAnimCurve,
      alignment: Alignment.topCenter,
      scale: isFocused ? 1.0 : 0.93,
      child: AnimatedContainer(
        duration: SavedCardsCardStackView.stackAnimDuration,
        curve: SavedCardsCardStackView.stackAnimCurve,
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
