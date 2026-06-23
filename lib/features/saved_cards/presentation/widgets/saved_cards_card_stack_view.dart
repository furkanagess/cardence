import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_list_logic.dart';
import '../cubit/saved_cards_state.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_focus_arrow_track.dart';
import 'saved_cards_saved_card_preview.dart';

class SavedCardsCardStackView extends StatefulWidget {
  const SavedCardsCardStackView({
    super.key,
    required this.displayCards,
    required this.state,
    required this.cubit,
    required this.useDummyCards,
    required this.onOpenCard,
  });

  static const Duration dragAnimDuration = Duration(milliseconds: 320);
  static const Curve dragAnimCurve = Curves.easeOutCubic;
  static const double cardVerticalStep = 64;

  final List<SavedCard> displayCards;
  final SavedCardsState state;
  final SavedCardsCubit cubit;
  final bool useDummyCards;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  @override
  State<SavedCardsCardStackView> createState() =>
      _SavedCardsCardStackViewState();
}

class _SavedCardsCardStackViewState extends State<SavedCardsCardStackView> {
  int _focusedIndex = 0;

  @override
  void didUpdateWidget(covariant SavedCardsCardStackView oldWidget) {
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

  double _cardTopFor(int index) {
    return SavedCardsListLogic.visualSlotFor(
          index: index,
          draggingIndex: widget.state.draggingCardIndex,
          hoverTargetIndex: widget.state.hoverTargetIndex,
        ) *
        SavedCardsCardStackView.cardVerticalStep;
  }

  List<double> _slotCenterYs() {
    return List<double>.generate(
      widget.displayCards.length,
      (index) =>
          _cardTopFor(index) + FlippablePersonCard.fixedHeight / 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const extraBottomPadding = 32.0;
    final cardsHeight = widget.displayCards.isEmpty
        ? 0.0
        : ((widget.displayCards.length - 1) *
                SavedCardsCardStackView.cardVerticalStep) +
            FlippablePersonCard.fixedHeight +
            extraBottomPadding;
    final slotCenters = _slotCenterYs();
    final isDragging = widget.state.draggingCardIndex != null;

    return SizedBox(
      height: cardsHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final i in _paintOrder(
                    widget.displayCards.length,
                    _focusedIndex,
                  ))
                    AnimatedPositioned(
                      duration: SavedCardsCardStackView.dragAnimDuration,
                      curve: SavedCardsCardStackView.dragAnimCurve,
                      top: _cardTopFor(i),
                      left: 0,
                      right: 0,
                      child: _StackCardSlot(
                        index: i,
                        displayCards: widget.displayCards,
                        state: widget.state,
                        cubit: widget.cubit,
                        useDummyCards: widget.useDummyCards,
                        isFocused: i == _focusedIndex && !isDragging,
                        maxWidth: constraints.maxWidth,
                        colorScheme: colorScheme,
                        onOpenCard: widget.onOpenCard,
                      ),
                    ),
                  if (widget.state.draggingCardIndex != null &&
                      widget.state.hoverTargetIndex != null &&
                      widget.state.draggingCardIndex !=
                          widget.state.hoverTargetIndex &&
                      widget.state.draggingCardIndex! >= 0 &&
                      widget.state.draggingCardIndex! <
                          widget.displayCards.length)
                    AnimatedPositioned(
                      duration: SavedCardsCardStackView.dragAnimDuration,
                      curve: SavedCardsCardStackView.dragAnimCurve,
                      top: (widget.state.hoverTargetIndex ?? 0) *
                          SavedCardsCardStackView.cardVerticalStep,
                      left: 0,
                      right: 0,
                      child: IgnorePointer(
                        child: _DropSlotCardPreview(
                          card: widget
                              .displayCards[widget.state.draggingCardIndex!],
                          colorScheme: colorScheme,
                          hoverTargetIndex: widget.state.hoverTargetIndex,
                        ),
                      ),
                    ),
                  if (widget.state.draggingCardIndex != null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 8,
                      child: IgnorePointer(
                        child: _DragHintChip(colorScheme: colorScheme),
                      ),
                    ),
                ],
              ),
              Positioned(
                left: 0,
                top: 0,
                width: SavedCardsFocusArrowTrack.width,
                height: cardsHeight,
                child: SavedCardsFocusArrowTrack(
                  trackHeight: cardsHeight,
                  slotCenterYs: slotCenters,
                  focusedIndex: _focusedIndex,
                  onFocusedIndexChanged: (index) {
                    setState(() => _focusedIndex = index);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StackCardSlot extends StatelessWidget {
  const _StackCardSlot({
    required this.index,
    required this.displayCards,
    required this.state,
    required this.cubit,
    required this.useDummyCards,
    required this.isFocused,
    required this.maxWidth,
    required this.colorScheme,
    required this.onOpenCard,
  });

  final int index;
  final List<SavedCard> displayCards;
  final SavedCardsState state;
  final SavedCardsCubit cubit;
  final bool useDummyCards;
  final bool isFocused;
  final double maxWidth;
  final ColorScheme colorScheme;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;

  @override
  Widget build(BuildContext context) {
    final isDragging = state.draggingCardIndex == index;
    final card = displayCards[index];
    final heroTag = 'saved-card-${card.cardId}';

    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onMove: (_) => cubit.setHoverTarget(index),
      onLeave: (_) {
        if (state.hoverTargetIndex != index) return;
        cubit.setHoverTarget(null);
      },
      onAcceptWithDetails: (details) {
        cubit.reorderCards(
          fromIndex: details.data,
          toIndex: index,
          useDummyCards: useDummyCards,
          displayCards: displayCards,
        );
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: index,
          dragAnchorStrategy: pointerDragAnchorStrategy,
          feedback: SizedBox(
            width: maxWidth,
            height: 1,
          ),
          childWhenDragging: _DragPlaceholder(colorScheme: colorScheme),
          onDragStarted: () {
            HapticFeedback.mediumImpact();
            cubit.startDrag(index);
          },
          onDragEnd: (_) => cubit.endDrag(),
          onDraggableCanceled: (_, __) => cubit.endDrag(),
          child: Opacity(
            opacity: isDragging ? 0.35 : 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: isFocused && !isDragging
                    ? [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.14),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: SavedCardsSavedCardPreview(
                card: card,
                heroTag: heroTag,
                wrapHero: !isDragging && isFocused,
                onDoubleTap: () => onOpenCard(card, heroTag: heroTag),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DragPlaceholder extends StatelessWidget {
  const _DragPlaceholder({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: SavedCardsCardStackView.dragAnimDuration,
      curve: SavedCardsCardStackView.dragAnimCurve,
      height: 24,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drag_handle_rounded,
            size: 20,
            color: colorScheme.primary.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }
}

class _DropSlotCardPreview extends StatelessWidget {
  const _DropSlotCardPreview({
    required this.card,
    required this.colorScheme,
    required this.hoverTargetIndex,
  });

  final SavedCard card;
  final ColorScheme colorScheme;
  final int? hoverTargetIndex;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(hoverTargetIndex),
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.primary, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: SavedCardsSavedCardPreview(card: card),
      ),
    );
  }
}

class _DragHintChip extends StatelessWidget {
  const _DragHintChip({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.swap_vert_rounded,
                size: 18,
                color: colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 8),
              Text(
                'Bırakmak için konumu seçin',
                style: TextStyle(
                  color: colorScheme.onInverseSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
