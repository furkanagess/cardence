import 'package:equatable/equatable.dart';

import '../../../event_groups/domain/entities/event_group.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import 'saved_cards_filter_models.dart';

enum SavedCardsEffectType {
  none,
  showSnackbar,
  openFilters,
  openAddCard,
  openUpgradeSheet,
}

class SavedCardsState extends Equatable {
  const SavedCardsState({
    this.cards = const [],
    this.dummyCardsOrder = const [],
    this.eventGroups = const [],
    this.quota,
    this.isLoadingCards = true,
    this.filter = const SavedCardsFilterSelection(
      eventFilter: SavedCardsFilterSelection.allEventsValue,
      dateFilter: SavedCardsDateFilter.all,
      nameSort: SavedCardsNameSort.asc,
    ),
    this.draggingCardIndex,
    this.hoverTargetIndex,
    this.effectType = SavedCardsEffectType.none,
    this.snackbarMessage,
    this.lastAddCardResult,
  });

  final List<SavedCard> cards;
  final List<SavedCard> dummyCardsOrder;
  final List<EventGroup> eventGroups;
  final SavedCardsWalletQuota? quota;
  final bool isLoadingCards;
  final SavedCardsFilterSelection filter;
  final int? draggingCardIndex;
  final int? hoverTargetIndex;
  final SavedCardsEffectType effectType;
  final String? snackbarMessage;
  final AddSavedCardResult? lastAddCardResult;

  bool get hasActiveFilters => filter.hasActiveFilters;
  int get activeFilterCount => filter.activeCount();

  SavedCardsState copyWith({
    List<SavedCard>? cards,
    List<SavedCard>? dummyCardsOrder,
    List<EventGroup>? eventGroups,
    SavedCardsWalletQuota? quota,
    bool? isLoadingCards,
    SavedCardsFilterSelection? filter,
    int? draggingCardIndex,
    int? hoverTargetIndex,
    bool clearDraggingCardIndex = false,
    bool clearHoverTargetIndex = false,
    SavedCardsEffectType? effectType,
    String? snackbarMessage,
    AddSavedCardResult? lastAddCardResult,
    bool clearEffect = false,
    bool clearLastAddCardResult = false,
  }) {
    return SavedCardsState(
      cards: cards ?? this.cards,
      dummyCardsOrder: dummyCardsOrder ?? this.dummyCardsOrder,
      eventGroups: eventGroups ?? this.eventGroups,
      quota: quota ?? this.quota,
      isLoadingCards: isLoadingCards ?? this.isLoadingCards,
      filter: filter ?? this.filter,
      draggingCardIndex: clearDraggingCardIndex
          ? null
          : (draggingCardIndex ?? this.draggingCardIndex),
      hoverTargetIndex: clearHoverTargetIndex
          ? null
          : (hoverTargetIndex ?? this.hoverTargetIndex),
      effectType: clearEffect
          ? SavedCardsEffectType.none
          : (effectType ?? this.effectType),
      snackbarMessage: clearEffect ? null : (snackbarMessage ?? this.snackbarMessage),
      lastAddCardResult: clearLastAddCardResult
          ? null
          : (lastAddCardResult ?? this.lastAddCardResult),
    );
  }

  @override
  List<Object?> get props => [
        cards,
        dummyCardsOrder,
        eventGroups,
        quota,
        isLoadingCards,
        filter,
        draggingCardIndex,
        hoverTargetIndex,
        effectType,
        snackbarMessage,
        lastAddCardResult,
      ];
}
