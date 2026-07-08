import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_focus_arrow_track.dart';
import 'saved_cards_horizontal_stack_view.dart';

/// Kaydedilen kartlar yatay şeridi: odaklı kart öne çıkar, kaydırınca index güncellenir.
class SavedCardsHorizontalCarousel extends StatefulWidget {
  const SavedCardsHorizontalCarousel({
    super.key,
    required this.cards,
    required this.onOpenCard,
    this.contentWidth,
    this.topPadding = 0,
  });

  final List<SavedCard> cards;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;
  final double? contentWidth;
  final double topPadding;

  static double resolveCardWidth(double contentWidth) {
    final ideal =
        FlippablePersonCard.fixedHeight * FlippablePersonCard.cardAspectRatio;
    return (contentWidth - 32).clamp(280.0, ideal);
  }

  static double sectionHeight(double cardWidth) =>
      SavedCardsHorizontalStackView.stackHeight + 52;

  @override
  State<SavedCardsHorizontalCarousel> createState() =>
      _SavedCardsHorizontalCarouselState();
}

class _SavedCardsHorizontalCarouselState extends State<SavedCardsHorizontalCarousel> {
  int _focusedIndex = 0;
  int _lastCardCount = 0;
  late final ScrollController _scrollController;
  bool _userDragging = false;
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
  void didUpdateWidget(covariant SavedCardsHorizontalCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncFocusForCardCount(widget.cards.length);
  }

  double _contentWidth(BuildContext context) {
    return widget.contentWidth ?? MediaQuery.sizeOf(context).width;
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

    final cardWidth = SavedCardsHorizontalCarousel.resolveCardWidth(
      _contentWidth(context),
    );
    final position = _scrollController.position;
    final left = SavedCardsHorizontalStackView.cardLeftForIndex(
      _focusedIndex,
      _focusedIndex,
      cardWidth,
    );
    final cardCenter = left + (cardWidth / 2);
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
      duration: SavedCardsHorizontalStackView.stackAnimDuration,
      curve: SavedCardsHorizontalStackView.stackAnimCurve,
    );
  }

  int _nearestFocusedIndexFromScroll(double cardWidth) {
    if (!_scrollController.hasClients || widget.cards.isEmpty) {
      return _focusedIndex;
    }

    final viewportCenter =
        _scrollController.offset + (_scrollController.position.viewportDimension / 2);

    var bestIndex = _focusedIndex;
    var bestDistance = double.infinity;

    for (var candidate = 0; candidate < widget.cards.length; candidate++) {
      final left = SavedCardsHorizontalStackView.cardLeftForIndex(
        candidate,
        candidate,
        cardWidth,
      );
      final center = left + (cardWidth / 2);
      final distance = (center - viewportCenter).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = candidate;
      }
    }

    return bestIndex;
  }

  void _syncFocusFromScroll(double cardWidth) {
    final nearest = _nearestFocusedIndexFromScroll(cardWidth);
    if (nearest == _focusedIndex) return;
    setState(() => _focusedIndex = nearest);
    _scheduleCenterFocusedCard(cardCount: widget.cards.length);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.horizontal) return false;

    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _userDragging = true;
    } else if (notification is ScrollEndNotification && _userDragging) {
      _userDragging = false;
      final cardWidth = SavedCardsHorizontalCarousel.resolveCardWidth(
        _contentWidth(context),
      );
      _syncFocusFromScroll(cardWidth);
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cards = widget.cards;
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final contentWidth = _contentWidth(context);
    final cardWidth = SavedCardsHorizontalCarousel.resolveCardWidth(contentWidth);
    final sidePadding = ((contentWidth - cardWidth) / 2).clamp(0.0, double.infinity);

    if (_lastCenteredFocusIndex != _focusedIndex ||
        _lastCenteredCardCount != cards.length) {
      _scheduleCenterFocusedCard(cardCount: cards.length);
    }

    return SizedBox(
      height: SavedCardsHorizontalCarousel.sectionHeight(cardWidth),
      child: Column(
        children: [
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleScrollNotification,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  widget.topPadding,
                  sidePadding,
                  0,
                ),
                child: SavedCardsHorizontalStackView(
                  displayCards: cards,
                  focusedIndex: _focusedIndex,
                  onFocusedIndexChanged: (index) => _setFocusedIndex(
                    index,
                    cardCount: cards.length,
                  ),
                  onOpenCard: widget.onOpenCard,
                  cardWidth: cardWidth,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SavedCardsFocusArrowTrack(
            axis: Axis.horizontal,
            focusedIndex: _focusedIndex,
            cardCount: cards.length,
            onFocusedIndexChanged: (index) => _setFocusedIndex(
              index,
              cardCount: cards.length,
            ),
          ),
        ],
      ),
    );
  }
}
