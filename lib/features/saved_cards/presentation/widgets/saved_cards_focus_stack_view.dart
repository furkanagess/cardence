import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_focus_arrow_track.dart';
import 'saved_cards_list_header.dart';
import 'saved_cards_saved_card_preview.dart';

/// Liste modunda: sol ok ile kart seçimi; seçili kart önde, diğerleri arkada.
class SavedCardsFocusStackView extends StatefulWidget {
  const SavedCardsFocusStackView({
    super.key,
    required this.displayCards,
    required this.onOpenCard,
    this.horizontalPadding = 16,
    this.topPadding = 8,
    this.bottomPadding = 96,
  });

  final List<SavedCard> displayCards;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;
  final double horizontalPadding;
  final double topPadding;
  final double bottomPadding;

  static const Duration _animDuration = Duration(milliseconds: 280);
  static const Curve _animCurve = Curves.easeOutCubic;

  @override
  State<SavedCardsFocusStackView> createState() =>
      _SavedCardsFocusStackViewState();
}

class _SavedCardsFocusStackViewState extends State<SavedCardsFocusStackView> {
  int _focusedIndex = 0;

  @override
  void didUpdateWidget(covariant SavedCardsFocusStackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_focusedIndex >= widget.displayCards.length) {
      _focusedIndex = widget.displayCards.isEmpty
          ? 0
          : widget.displayCards.length - 1;
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

  List<double> _slotCenterYs(double trackHeight, int count) {
    if (count <= 0) return const [];
    if (count == 1) return [trackHeight / 2];

    const edgeInset = 36.0;
    final usable = trackHeight - edgeInset * 2;
    return List<double>.generate(
      count,
      (index) => edgeInset + usable * index / (count - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        widget.horizontalPadding,
        widget.topPadding,
        widget.horizontalPadding,
        widget.bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SavedCardsListHeader(count: widget.displayCards.length),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackHeight = constraints.maxHeight;
                final slotCenters =
                    _slotCenterYs(trackHeight, widget.displayCards.length);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SavedCardsFocusArrowTrack(
                      trackHeight: trackHeight,
                      slotCenterYs: slotCenters,
                      focusedIndex: _focusedIndex,
                      onFocusedIndexChanged: (index) {
                        setState(() => _focusedIndex = index);
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          height: FlippablePersonCard.fixedHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.topCenter,
                            children: [
                              for (final index in _paintOrder(
                                widget.displayCards.length,
                                _focusedIndex,
                              ))
                                _FocusedDeckCard(
                                  key: ValueKey(
                                    widget.displayCards[index].cardId,
                                  ),
                                  card: widget.displayCards[index],
                                  isFocused: index == _focusedIndex,
                                  stackDepth: (index - _focusedIndex).abs(),
                                  isBeforeFocus: index < _focusedIndex,
                                  colorScheme: colorScheme,
                                  onOpenCard: widget.onOpenCard,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusedDeckCard extends StatelessWidget {
  const _FocusedDeckCard({
    super.key,
    required this.card,
    required this.isFocused,
    required this.stackDepth,
    required this.isBeforeFocus,
    required this.colorScheme,
    required this.onOpenCard,
  });

  final SavedCard card;
  final bool isFocused;
  final int stackDepth;
  final bool isBeforeFocus;
  final ColorScheme colorScheme;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  @override
  Widget build(BuildContext context) {
    final heroTag = 'saved-card-${card.cardId}';
    final depth = isFocused ? 0 : stackDepth.clamp(1, 4);
    final verticalOffset = isFocused
        ? 0.0
        : (isBeforeFocus ? -depth * 10.0 : depth * 6.0);
    final horizontalOffset = isFocused ? 0.0 : depth * 6.0;
    final scale = isFocused ? 1.0 : (1.0 - depth * 0.03).clamp(0.86, 0.97);
    final opacity = isFocused ? 1.0 : (0.55 - depth * 0.08).clamp(0.28, 0.55);

    return AnimatedPositioned(
      duration: SavedCardsFocusStackView._animDuration,
      curve: SavedCardsFocusStackView._animCurve,
      top: verticalOffset,
      left: horizontalOffset,
      right: horizontalOffset,
      child: AnimatedOpacity(
        duration: SavedCardsFocusStackView._animDuration,
        curve: SavedCardsFocusStackView._animCurve,
        opacity: opacity,
        child: AnimatedScale(
          duration: SavedCardsFocusStackView._animDuration,
          curve: SavedCardsFocusStackView._animCurve,
          scale: scale,
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: isFocused
                  ? [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.16),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: SavedCardsSavedCardPreview(
              card: card,
              heroTag: heroTag,
              wrapHero: isFocused,
              onDoubleTap: () => onOpenCard(card, heroTag: heroTag),
            ),
          ),
        ),
      ),
    );
  }
}
