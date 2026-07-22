import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/entities/wallet_card_invitation.dart';
import '../../domain/usecases/accept_wallet_card_invitation.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../domain/usecases/get_wallet_card_invitations.dart';
import '../../domain/usecases/reject_wallet_card_invitation.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
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
    required GetWalletCardInvitations getWalletCardInvitations,
    required AcceptWalletCardInvitation acceptWalletCardInvitation,
    required RejectWalletCardInvitation rejectWalletCardInvitation,
  })  : _getSavedCards = getSavedCards,
        _saveSavedCard = saveSavedCard,
        _getEventGroups = getEventGroups,
        _getSavedCardsWalletQuota = getSavedCardsWalletQuota,
        _upgradeWalletPlan = upgradeWalletPlan,
        _getWalletCardInvitations = getWalletCardInvitations,
        _acceptWalletCardInvitation = acceptWalletCardInvitation,
        _rejectWalletCardInvitation = rejectWalletCardInvitation,
        super(const SavedCardsState());

  final GetSavedCards _getSavedCards;
  final SaveSavedCard _saveSavedCard;
  final GetEventGroups _getEventGroups;
  final GetSavedCardsWalletQuota _getSavedCardsWalletQuota;
  final UpgradeWalletPlan _upgradeWalletPlan;
  final GetWalletCardInvitations _getWalletCardInvitations;
  final AcceptWalletCardInvitation _acceptWalletCardInvitation;
  final RejectWalletCardInvitation _rejectWalletCardInvitation;

  List<SavedCard> get sourceCards => state.cards;

  Future<void> load() => refreshAll();

  Future<void> refreshAll() async {
    await Future.wait([
      _loadCardsSafely(),
      _loadEventGroupsSafely(),
      _loadQuotaSafely(),
      _loadInvitationsSafely(),
    ]);
  }

  Future<void> _loadCardsSafely() async {
    try {
      await _loadCards();
    } on AuthApiException {
      if (isClosed) return;
      emit(state.copyWith(isLoadingCards: false));
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
      if (isClosed) return;
      emit(
        state.copyWith(
          quota: _fallbackQuota(),
          isLoadingQuota: false,
        ),
      );
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          quota: _fallbackQuota(),
          isLoadingQuota: false,
        ),
      );
    }
  }

  Future<void> _loadInvitationsSafely() async {
    try {
      await _loadInvitations();
    } on AuthApiException {
      // Endpoint henüz production'da olmayabilir.
    } catch (_) {}
  }

  SavedCardsWalletQuota _fallbackQuota() {
    return SavedCardsWalletQuota.freeDefault(
      usedCount: state.cards.length,
      eventGroupCount: state.eventGroups.length,
    );
  }

  void _syncDefaultQuotaCounts() {
    if (!state.isLoadingQuota) return;
    emit(
      state.copyWith(
        quota: state.quota.withCounts(
          usedCount: state.cards.length,
          eventGroupCount: state.eventGroups.length,
        ),
      ),
    );
  }

  Future<void> _loadQuota() async {
    emit(state.copyWith(isLoadingQuota: true));
    final quota = await _getSavedCardsWalletQuota();
    if (isClosed) return;
    emit(state.copyWith(quota: quota, isLoadingQuota: false));
  }

  Future<void> _loadEventGroups() async {
    final groups = await _getEventGroups();
    if (isClosed) return;
    emit(state.copyWith(eventGroups: groups));
    _syncDefaultQuotaCounts();
  }

  Future<void> _loadCards() async {
    final list = await _getSavedCards();
    if (isClosed) return;
    emit(
      state.copyWith(
        cards: list,
        isLoadingCards: false,
      ),
    );
    _syncDefaultQuotaCounts();
  }

  Future<void> _loadInvitations() async {
    final invitations = await _getWalletCardInvitations();
    if (isClosed) return;
    emit(state.copyWith(invitations: invitations));
  }

  Future<void> respondToInvitation({
    required WalletCardInvitation invitation,
    required bool accept,
  }) async {
    if (state.respondingInvitationId != null) return;

    if (accept && !state.quota.canAddMore) {
      emit(state.copyWith(effectType: SavedCardsEffectType.invitationQuotaFull));
      return;
    }

    emit(state.copyWith(respondingInvitationId: invitation.id));
    try {
      if (accept) {
        await _acceptWalletCardInvitation(invitation.id);
      } else {
        await _rejectWalletCardInvitation(invitation.id);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          clearRespondingInvitationId: true,
          effectType: accept
              ? SavedCardsEffectType.invitationAccepted
              : SavedCardsEffectType.invitationRejected,
        ),
      );
      await refreshAll();
    } on AuthApiException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(clearRespondingInvitationId: true));
      if (accept &&
          (e.errorCode == 'WALLET_LIMIT_REACHED' ||
              e.errorCode == 'PLAN_LIMIT_REACHED')) {
        emit(
          state.copyWith(effectType: SavedCardsEffectType.invitationQuotaFull),
        );
      }
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(clearRespondingInvitationId: true));
    }
  }

  void clearEffect() {
    if (state.effectType == SavedCardsEffectType.none) return;
    emit(state.copyWith(clearEffect: true));
  }

  void requestOpenFilters() {
    emit(
      state.copyWith(
        effectType: SavedCardsEffectType.openFilters,
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
    emit(state.copyWith(filter: selection));
  }

  void clearFilters() {
    emit(state.copyWith(filter: state.filter.cleared()));
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    emit(state.copyWith(searchQuery: query));
  }

  void clearSearch() {
    if (!state.hasActiveSearch) return;
    emit(state.copyWith(searchQuery: ''));
  }

  List<({String value, String label})> eventFilterOptionsForSource(
    AppLocalizations l10n,
    List<SavedCard> sourceCards,
  ) {
    return SavedCardsListLogic.eventFilterOptions(
      l10n: l10n,
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

  Future<void> persistCardUpdate(SavedCard updated) async {
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
    final quota = state.isLoadingQuota
        ? await _getSavedCardsWalletQuota()
        : state.quota;
    if (isClosed) return;
    emit(state.copyWith(quota: quota, isLoadingQuota: false));

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
      case AddSavedCardDuplicate():
      case AddSavedCardOwnCard():
        break;
      case AddSavedCardLimitReached():
        emit(state.copyWith(effectType: SavedCardsEffectType.openUpgradeSheet));
      case AddSavedCardPremiumRequired():
        emit(state.copyWith(effectType: SavedCardsEffectType.openUpgradeSheet));
      case AddSavedCardInvalidPayload():
        break;
    }
  }

  Future<bool> upgradeWallet({
    bool onlyIfNeeded = false,
    bool? useDarkAppearance,
    String? preferredLocale,
  }) async {
    try {
      final success = await _upgradeWalletPlan(
        onlyIfNeeded: onlyIfNeeded,
        useDarkAppearance: useDarkAppearance,
        preferredLocale: preferredLocale,
      );
      if (isClosed) return false;
      if (success) {
        await refreshAll();
      } else {
        await _loadQuota();
      }
      return success;
    } catch (_) {
      if (!isClosed) {
        await _loadQuota();
      }
      return false;
    }
  }
}
