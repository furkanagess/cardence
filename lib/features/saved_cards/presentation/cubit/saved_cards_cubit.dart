import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_api_exception.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
import '../saved_cards_catalog.dart';
import 'saved_cards_filter_models.dart';
import 'saved_cards_list_logic.dart';
import 'saved_cards_state.dart';

class SavedCardsCubit extends Cubit<SavedCardsState> {
  SavedCardsCubit({
    required GetSavedCards getSavedCards,
    required SaveSavedCard saveSavedCard,
    required GetEventGroups getEventGroups,
    required GetSavedCardsWalletQuota getSavedCardsWalletQuota,
    required UpgradeWalletPlan upgradeWalletPlan,
  })  : _getSavedCards = getSavedCards,
        _saveSavedCard = saveSavedCard,
        _getEventGroups = getEventGroups,
        _getSavedCardsWalletQuota = getSavedCardsWalletQuota,
        _upgradeWalletPlan = upgradeWalletPlan,
        super(const SavedCardsState());

  final GetSavedCards _getSavedCards;
  final SaveSavedCard _saveSavedCard;
  final GetEventGroups _getEventGroups;
  final GetSavedCardsWalletQuota _getSavedCardsWalletQuota;
  final UpgradeWalletPlan _upgradeWalletPlan;

  List<SavedCard> get sourceCards {
    final useDummyCards = SavedCardsCatalog.isUsingDemoCards(state.cards);
    return useDummyCards ? state.dummyCardsOrder : state.cards;
  }

  Future<void> load() => refreshAll();

  Future<void> refreshAll() async {
    await Future.wait([
      _loadCardsSafely(),
      _loadEventGroupsSafely(),
      _loadQuotaSafely(),
    ]);
  }

  Future<void> _loadCardsSafely() async {
    try {
      await _loadCards();
    } on AuthApiException catch (error) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingCards: false,
          effectType: SavedCardsEffectType.showSnackbar,
          snackbarMessage: error.message,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingCards: false));
    }
  }

  Future<void> _loadEventGroupsSafely() async {
    try {
      await _loadEventGroups();
    } on AuthApiException {
      // Etkinlik grupları yüklenemezse filtreler yerel veriyle çalışmaya devam eder.
    } catch (_) {}
  }

  Future<void> _loadQuotaSafely() async {
    try {
      await _loadQuota();
    } on AuthApiException {
      // Kota alınamazsa mevcut kota değeri korunur.
    } catch (_) {}
  }

  Future<void> _loadQuota() async {
    final quota = await _getSavedCardsWalletQuota();
    if (isClosed) return;
    emit(state.copyWith(quota: quota));
  }

  Future<void> _loadEventGroups() async {
    final groups = await _getEventGroups();
    if (isClosed) return;
    emit(state.copyWith(eventGroups: groups));
  }

  Future<void> _loadCards() async {
    final list = await _getSavedCards();
    if (isClosed) return;
    emit(
      state.copyWith(
        cards: list,
        isLoadingCards: false,
        dummyCardsOrder: SavedCardsCatalog.isUsingDemoCards(list)
            ? SavedCardsCatalog.demoDisplayList(list)
            : state.dummyCardsOrder,
      ),
    );
  }

  void clearEffect() {
    if (state.effectType == SavedCardsEffectType.none) return;
    emit(state.copyWith(clearEffect: true));
  }

  void requestOpenFilters() {
    emit(
      state.copyWith(
        effectType: SavedCardsEffectType.openFilters,
        clearDraggingCardIndex: true,
        clearHoverTargetIndex: true,
      ),
    );
  }

  void requestAddCard() {
    emit(state.copyWith(effectType: SavedCardsEffectType.openAddCard));
  }

  void requestUpgradeSheet() {
    emit(state.copyWith(effectType: SavedCardsEffectType.openUpgradeSheet));
  }

  void applyFilter(SavedCardsFilterSelection selection) {
    emit(
      state.copyWith(
        filter: selection,
        clearDraggingCardIndex: true,
        clearHoverTargetIndex: true,
      ),
    );
  }

  void clearFilters() {
    emit(
      state.copyWith(
        filter: state.filter.cleared(),
        clearDraggingCardIndex: true,
        clearHoverTargetIndex: true,
      ),
    );
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    emit(
      state.copyWith(
        searchQuery: query,
        clearDraggingCardIndex: true,
        clearHoverTargetIndex: true,
      ),
    );
  }

  void clearSearch() {
    if (!state.hasActiveSearch) return;
    emit(
      state.copyWith(
        searchQuery: '',
        clearDraggingCardIndex: true,
        clearHoverTargetIndex: true,
      ),
    );
  }

  List<({String value, String label})> eventFilterOptionsForSource(
    List<SavedCard> sourceCards,
  ) {
    return SavedCardsListLogic.eventFilterOptions(
      sourceCards: sourceCards,
      eventGroups: state.eventGroups,
    );
  }

  List<SavedCard> displayCardsFor(List<SavedCard> sourceCards) {
    return SavedCardsListLogic.applyFiltersSortAndSearch(
      cards: sourceCards,
      filter: state.filter,
      searchQuery: state.searchQuery,
    );
  }

  void startDrag(int index) {
    emit(
      state.copyWith(
        draggingCardIndex: index,
        clearHoverTargetIndex: true,
      ),
    );
  }

  void setHoverTarget(int? index) {
    if (state.hoverTargetIndex == index) return;
    emit(state.copyWith(hoverTargetIndex: index));
  }

  void endDrag() {
    emit(
      state.copyWith(
        clearDraggingCardIndex: true,
        clearHoverTargetIndex: true,
      ),
    );
  }

  void reorderCards({
    required int fromIndex,
    required int toIndex,
    required bool useDummyCards,
    required List<SavedCard> displayCards,
  }) {
    if (fromIndex == toIndex) {
      endDrag();
      return;
    }

    final targetList = useDummyCards ? state.dummyCardsOrder : state.cards;
    final reordered = SavedCardsListLogic.reorderCards(
      targetList: targetList,
      displayCards: displayCards,
      fromIndex: fromIndex,
      toIndex: toIndex,
      filtersActive: state.hasActiveFilters,
    );

    emit(
      state.copyWith(
        cards: useDummyCards ? state.cards : reordered,
        dummyCardsOrder: useDummyCards ? reordered : state.dummyCardsOrder,
        clearDraggingCardIndex: true,
        clearHoverTargetIndex: true,
      ),
    );
  }

  Future<void> persistCardUpdate(SavedCard updated) async {
    if (SavedCardsCatalog.isUsingDemoCards(state.cards)) {
      final nextDummy = state.dummyCardsOrder
          .map((c) => c.cardId == updated.cardId ? updated : c)
          .toList();
      emit(state.copyWith(dummyCardsOrder: nextDummy));
      if (state.cards.isEmpty) return;
    }

    await _saveSavedCard(updated);
    if (isClosed) return;
    emit(
      state.copyWith(
        cards: state.cards
            .map((c) => c.cardId == updated.cardId ? updated : c)
            .toList(),
      ),
    );
  }

  Future<void> handleAddCardTap() async {
    final quota = state.quota ?? await _getSavedCardsWalletQuota();
    if (isClosed) return;
    if (quota != state.quota) {
      emit(state.copyWith(quota: quota));
    }

    if (!quota.canAddMore) {
      emit(state.copyWith(effectType: SavedCardsEffectType.openUpgradeSheet));
      return;
    }

    emit(state.copyWith(effectType: SavedCardsEffectType.openAddCard));
  }

  Future<void> handleAddCardResult(AddSavedCardResult? result) async {
    if (result == null) return;
    emit(state.copyWith(lastAddCardResult: result));

    switch (result) {
      case AddSavedCardSuccess():
        await refreshAll();
        if (isClosed) return;
        emit(
          state.copyWith(
            effectType: SavedCardsEffectType.showSnackbar,
            snackbarMessage: 'Kart cüzdanınıza eklendi',
          ),
        );
      case AddSavedCardDuplicate():
        emit(
          state.copyWith(
            effectType: SavedCardsEffectType.showSnackbar,
            snackbarMessage: 'Bu kart zaten kayıtlı',
          ),
        );
      case AddSavedCardLimitReached():
        emit(state.copyWith(effectType: SavedCardsEffectType.openUpgradeSheet));
      case AddSavedCardPremiumRequired():
        emit(state.copyWith(effectType: SavedCardsEffectType.openUpgradeSheet));
      case AddSavedCardInvalidPayload(:final message):
        emit(
          state.copyWith(
            effectType: SavedCardsEffectType.showSnackbar,
            snackbarMessage: message,
          ),
        );
    }
  }

  Future<bool> upgradeWallet() async {
    final success = await _upgradeWalletPlan();
    if (isClosed) return false;
    await _loadQuota();
    return success;
  }
}
