import 'package:equatable/equatable.dart';

import '../../../event_groups/domain/entities/event_group.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/entities/wallet_card_invitation.dart';
import '../../domain/entities/wallet_plan_tier.dart';
import '../../domain/saved_cards_wallet_limits.dart';
import 'saved_cards_filter_models.dart';

enum SavedCardsEffectType {
  none,
  openFilters,
  openAddCard,
  openUpgradeSheet,
  invitationAccepted,
  invitationRejected,
  invitationQuotaFull,
}

class SavedCardsState extends Equatable {
  static const SavedCardsWalletQuota _initialQuota = SavedCardsWalletQuota(
    tier: WalletPlanTier.free,
    usedCount: 0,
    maxCards: SavedCardsWalletLimits.freeMaxCards,
  );

  const SavedCardsState({
    this.cards = const [],
    this.eventGroups = const [],
    this.invitations = const [],
    this.quota = _initialQuota,
    this.isLoadingQuota = true,
    this.isLoadingCards = true,
    this.respondingInvitationId,
    this.filter = const SavedCardsFilterSelection(
      eventFilter: SavedCardsFilterSelection.allEventsValue,
      dateFilter: SavedCardsDateFilter.all,
      nameSort: SavedCardsNameSort.asc,
    ),
    this.searchQuery = '',
    this.effectType = SavedCardsEffectType.none,
    this.lastAddCardResult,
  });

  final List<SavedCard> cards;
  final List<EventGroup> eventGroups;
  final List<WalletCardInvitation> invitations;
  final SavedCardsWalletQuota quota;
  final bool isLoadingQuota;
  final bool isLoadingCards;
  final String? respondingInvitationId;
  final SavedCardsFilterSelection filter;
  final String searchQuery;
  final SavedCardsEffectType effectType;
  final AddSavedCardResult? lastAddCardResult;

  bool get hasActiveFilters => filter.hasActiveFilters;
  bool get hasActiveSearch => searchQuery.trim().isNotEmpty;
  int get activeFilterCount => filter.activeCount();

  SavedCardsState copyWith({
    List<SavedCard>? cards,
    List<EventGroup>? eventGroups,
    List<WalletCardInvitation>? invitations,
    SavedCardsWalletQuota? quota,
    bool? isLoadingQuota,
    bool? isLoadingCards,
    String? respondingInvitationId,
    bool clearRespondingInvitationId = false,
    SavedCardsFilterSelection? filter,
    String? searchQuery,
    SavedCardsEffectType? effectType,
    AddSavedCardResult? lastAddCardResult,
    bool clearEffect = false,
    bool clearLastAddCardResult = false,
  }) {
    return SavedCardsState(
      cards: cards ?? this.cards,
      eventGroups: eventGroups ?? this.eventGroups,
      invitations: invitations ?? this.invitations,
      quota: quota ?? this.quota,
      isLoadingQuota: isLoadingQuota ?? this.isLoadingQuota,
      isLoadingCards: isLoadingCards ?? this.isLoadingCards,
      respondingInvitationId: clearRespondingInvitationId
          ? null
          : (respondingInvitationId ?? this.respondingInvitationId),
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
      effectType: clearEffect
          ? SavedCardsEffectType.none
          : (effectType ?? this.effectType),
      lastAddCardResult: clearLastAddCardResult
          ? null
          : (lastAddCardResult ?? this.lastAddCardResult),
    );
  }

  @override
  List<Object?> get props => [
        cards,
        eventGroups,
        invitations,
        quota,
        isLoadingQuota,
        isLoadingCards,
        respondingInvitationId,
        filter,
        searchQuery,
        effectType,
        lastAddCardResult,
      ];
}
