import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_list_logic.dart';
import '../cubit/saved_cards_state.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_saved_card_preview.dart';

class SavedCardsCardStackView extends StatelessWidget {
  const SavedCardsCardStackView({
    super.key,
    required this.displayCards,
    required this.state,
    required this.cubit,
    required this.useDummyCards,
    required this.onOpenCard,
    required this.onEditNote,
  });

  static const Duration dragAnimDuration = Duration(milliseconds: 320);
  static const Curve dragAnimCurve = Curves.easeOutCubic;
  static const double cardVerticalStep = 64;

  final List<SavedCard> displayCards;
  final SavedCardsState state;
  final SavedCardsCubit cubit;
  final bool useDummyCards;
  final void Function(SavedCard card, {String? heroTag}) onOpenCard;
  final void Function(SavedCard card) onEditNote;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const extraBottomPadding = 32.0;
    final cardsHeight = displayCards.isEmpty
        ? 0.0
        : ((displayCards.length - 1) * cardVerticalStep) + 260 + extraBottomPadding;

    return SizedBox(
      height: cardsHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              for (final i in List<int>.generate(displayCards.length, (index) => index))
                AnimatedPositioned(
                  duration: dragAnimDuration,
                  curve: dragAnimCurve,
                  top: _cardTopFor(i),
                  left: 0,
                  right: 0,
                  child: DragTarget<int>(
                    onWillAcceptWithDetails: (details) => details.data != i,
                    onMove: (_) => cubit.setHoverTarget(i),
                    onLeave: (_) {
                      if (state.hoverTargetIndex != i) return;
                      cubit.setHoverTarget(null);
                    },
                    onAcceptWithDetails: (details) {
                      cubit.reorderCards(
                        fromIndex: details.data,
                        toIndex: i,
                        useDummyCards: useDummyCards,
                        displayCards: displayCards,
                      );
                    },
                    builder: (context, candidateData, rejectedData) {
                      final isDragging = state.draggingCardIndex == i;
                      final card = displayCards[i];
                      final heroTag = 'saved-card-${card.cardId}';

                      return LongPressDraggable<int>(
                        data: i,
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        feedback: SizedBox(
                          width: constraints.maxWidth,
                          height: 1,
                        ),
                        childWhenDragging: _DragPlaceholder(colorScheme: colorScheme),
                        onDragStarted: () {
                          HapticFeedback.mediumImpact();
                          cubit.startDrag(i);
                        },
                        onDragEnd: (_) => cubit.endDrag(),
                        onDraggableCanceled: (_, __) => cubit.endDrag(),
                        child: SavedCardsSavedCardPreview(
                          card: card,
                          heroTag: heroTag,
                          wrapHero: !isDragging,
                          onTap: () => onOpenCard(card, heroTag: heroTag),
                          onEditNote: () => onEditNote(card),
                        ),
                      );
                    },
                  ),
                ),
              if (state.draggingCardIndex != null &&
                  state.hoverTargetIndex != null &&
                  state.draggingCardIndex != state.hoverTargetIndex &&
                  state.draggingCardIndex! >= 0 &&
                  state.draggingCardIndex! < displayCards.length)
                AnimatedPositioned(
                  duration: dragAnimDuration,
                  curve: dragAnimCurve,
                  top: (state.hoverTargetIndex ?? 0) * cardVerticalStep,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: _DropSlotCardPreview(
                      card: displayCards[state.draggingCardIndex!],
                      colorScheme: colorScheme,
                      hoverTargetIndex: state.hoverTargetIndex,
                    ),
                  ),
                ),
              if (state.draggingCardIndex != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 8,
                  child: IgnorePointer(
                    child: _DragHintChip(colorScheme: colorScheme),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _cardTopFor(int index) {
    return SavedCardsListLogic.visualSlotFor(
          index: index,
          draggingIndex: state.draggingCardIndex,
          hoverTargetIndex: state.hoverTargetIndex,
        ) *
        cardVerticalStep;
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
