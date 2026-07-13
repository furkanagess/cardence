import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_card_stack_view.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_focus_arrow_track.dart';

/// Etkinlik detayında gruptaki kartlar — kaydedilen kartlar ekranıyla aynı dikey yığın.
class EventGroupDetailLinkedCardsSection extends StatefulWidget {
  const EventGroupDetailLinkedCardsSection({
    super.key,
    required this.cards,
    required this.onOpenCard,
  });

  final List<SavedCard> cards;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  static const double _horizontalPadding = 20;
  static const double _topPadding = 4;
  static const double _bottomPadding = 16;

  @override
  State<EventGroupDetailLinkedCardsSection> createState() =>
      _EventGroupDetailLinkedCardsSectionState();
}

class _EventGroupDetailLinkedCardsSectionState
    extends State<EventGroupDetailLinkedCardsSection> {
  int _focusedIndex = 0;
  int _lastCardCount = 0;
  late final ScrollController _scrollController;
  int? _lastCenteredFocusIndex;
  int? _lastCenteredCardCount;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _lastCardCount = widget.cards.length;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EventGroupDetailLinkedCardsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFocusForCardCount(widget.cards.length);
  }

  void _syncFocusForCardCount(int cardCount) {
    if (cardCount == _lastCardCount) return;
    _lastCardCount = cardCount;
    if (_focusedIndex >= cardCount && cardCount > 0) {
      _focusedIndex = cardCount - 1;
    } else if (cardCount == 0) {
      _focusedIndex = 0;
    }
    _scheduleCenterFocusedCard(cardCount: cardCount);
  }

  void _setFocusedIndex(int index, {required int cardCount}) {
    if (index < 0 || index >= cardCount) return;
    if (_focusedIndex == index) {
      _scheduleCenterFocusedCard(cardCount: cardCount);
      return;
    }
    setState(() => _focusedIndex = index);
    _scheduleCenterFocusedCard(cardCount: cardCount);
  }

  void _scheduleCenterFocusedCard({required int cardCount}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centerFocusedCard(cardCount: cardCount);
    });
  }

  void _centerFocusedCard({required int cardCount}) {
    if (!_scrollController.hasClients || cardCount == 0) return;

    final position = _scrollController.position;
    final cardTop = SavedCardsCardStackView.cardTopForIndex(
          _focusedIndex,
          _focusedIndex,
        ) +
        EventGroupDetailLinkedCardsSection._topPadding;
    final cardCenter = cardTop + (FlippablePersonCard.fixedHeight / 2);
    final targetOffset = cardCenter - (position.viewportDimension / 2);
    final clamped = targetOffset.clamp(0.0, position.maxScrollExtent);

    _lastCenteredFocusIndex = _focusedIndex;
    _lastCenteredCardCount = cardCount;

    if ((position.pixels - clamped).abs() < 1) {
      _scrollController.jumpTo(clamped);
      return;
    }

    _scrollController.animateTo(
      clamped,
      duration: SavedCardsCardStackView.stackAnimDuration,
      curve: SavedCardsCardStackView.stackAnimCurve,
    );
  }

  double _sectionHeight(int cardCount, int focusedIndex, double viewportHeight) {
    final contentHeight =
        SavedCardsCardStackView.stackContentHeight(cardCount, focusedIndex);
    final maxHeight = (viewportHeight * 0.52).clamp(300.0, 480.0);
    if (contentHeight <= maxHeight) return contentHeight;
    return maxHeight;
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final viewportHeight = MediaQuery.sizeOf(context).height;
    final sectionHeight = _sectionHeight(
      cards.length,
      _focusedIndex,
      viewportHeight,
    );

    if (_lastCenteredFocusIndex != _focusedIndex ||
        _lastCenteredCardCount != cards.length) {
      _scheduleCenterFocusedCard(cardCount: cards.length);
    }

    return SizedBox(
      height: sectionHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(
              EventGroupDetailLinkedCardsSection._horizontalPadding,
              EventGroupDetailLinkedCardsSection._topPadding,
              EventGroupDetailLinkedCardsSection._horizontalPadding,
              EventGroupDetailLinkedCardsSection._bottomPadding,
            ),
            child: SavedCardsCardStackView(
              displayCards: cards,
              focusedIndex: _focusedIndex,
              onFocusedIndexChanged: (index) => _setFocusedIndex(
                index,
                cardCount: cards.length,
              ),
              onOpenCard: widget.onOpenCard,
            ),
          ),
          Positioned(
            left: 2,
            top: 0,
            bottom: 0,
            child: Center(
              child: SavedCardsFocusArrowTrack(
                focusedIndex: _focusedIndex,
                cardCount: cards.length,
                onFocusedIndexChanged: (index) => _setFocusedIndex(
                  index,
                  cardCount: cards.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
