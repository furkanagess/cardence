import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/delete_event_group.dart';
import '../../../event_groups/domain/usecases/update_event_group.dart';
import '../../../event_groups/domain/usecases/invite_event_group_cards_by_card_id.dart';
import '../../../event_groups/domain/usecases/get_event_group_outbound_invitations.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/usecases/link_saved_cards_to_event_group.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../../domain/usecases/delete_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/track_saved_card_contact_click.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
import '../../../subscriptions/domain/usecases/restore_wallet_purchases.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_state.dart';
import '../mixins/saved_cards_page_effects_mixin.dart';
import '../widgets/saved_cards_add_card_fab.dart';
import '../widgets/saved_cards_card_stack_view.dart';
import '../widgets/saved_cards_empty_results_view.dart';
import '../widgets/saved_cards_focus_arrow_track.dart';
import '../widgets/saved_cards_loading_shimmer.dart';
import '../widgets/saved_cards_screen_toolbar.dart';
/// Kaydettiği kişilerin kartları listesi (yalnızca görünüm katmanı).
class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({
    super.key,
    required this.filterTrigger,
    this.addCardTrigger = 0,
    required this.addSavedCard,
    required this.upgradeWalletPlan,
    required this.restoreWalletPurchases,
    required this.getEventGroups,
    required this.getSavedCards,
    required this.updateEventGroup,
    required this.inviteEventGroupCardsByCardId,
    required this.getEventGroupOutboundInvitations,
    required this.deleteEventGroup,
    required this.linkSavedCardsToEventGroup,
    required this.saveSavedCard,
    required this.deleteSavedCard,
    required this.trackSavedCardContactClick,
  });

  final int filterTrigger;
  final int addCardTrigger;
  final AddSavedCard addSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;
  final RestoreWalletPurchases restoreWalletPurchases;
  final GetEventGroups getEventGroups;
  final GetSavedCards getSavedCards;
  final UpdateEventGroup updateEventGroup;
  final InviteEventGroupCardsByCardId inviteEventGroupCardsByCardId;
  final GetEventGroupOutboundInvitations getEventGroupOutboundInvitations;
  final DeleteEventGroup deleteEventGroup;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final SaveSavedCard saveSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final TrackSavedCardContactClick trackSavedCardContactClick;

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage>
    with SavedCardsPageEffectsMixin {
  int _stackFocusedIndex = 0;
  int _lastStackCardCount = 0;
  late final ScrollController _stackScrollController;
  int? _lastCenteredFocusIndex;
  int? _lastCenteredCardCount;

  @override
  void initState() {
    super.initState();
    _stackScrollController = ScrollController();
  }

  @override
  void dispose() {
    _stackScrollController.dispose();
    super.dispose();
  }

  void _setStackFocusedIndex(
    int index, {
    required double topPadding,
    required int cardCount,
  }) {
    if (_stackFocusedIndex == index) {
      _scheduleCenterFocusedStackCard(
        topPadding: topPadding,
        cardCount: cardCount,
      );
      return;
    }
    setState(() => _stackFocusedIndex = index);
    _scheduleCenterFocusedStackCard(
      topPadding: topPadding,
      cardCount: cardCount,
    );
  }

  void _scheduleCenterFocusedStackCard({
    required double topPadding,
    required int cardCount,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centerFocusedStackCard(topPadding: topPadding, cardCount: cardCount);
    });
  }

  void _centerFocusedStackCard({
    required double topPadding,
    required int cardCount,
  }) {
    if (!_stackScrollController.hasClients) return;

    final position = _stackScrollController.position;
    final cardTop = SavedCardsCardStackView.cardTopForIndex(
          _stackFocusedIndex,
          _stackFocusedIndex,
        ) +
        topPadding;
    final cardCenter = cardTop + (FlippablePersonCard.fixedHeight / 2);
    final targetOffset = cardCenter - (position.viewportDimension / 2);
    final clamped = targetOffset.clamp(0.0, position.maxScrollExtent);

    _lastCenteredFocusIndex = _stackFocusedIndex;
    _lastCenteredCardCount = cardCount;

    if ((position.pixels - clamped).abs() < 1) {
      _stackScrollController.jumpTo(clamped);
      return;
    }

    _stackScrollController.animateTo(
      clamped,
      duration: SavedCardsCardStackView.stackAnimDuration,
      curve: SavedCardsCardStackView.stackAnimCurve,
    );
  }

  void _syncStackFocus(
    int cardCount, {
    required double topPadding,
  }) {
    final countChanged = cardCount != _lastStackCardCount;
    if (!countChanged) return;

    _lastStackCardCount = cardCount;
    if (_stackFocusedIndex >= cardCount && cardCount > 0) {
      _stackFocusedIndex = cardCount - 1;
      _scheduleCenterFocusedStackCard(
        topPadding: topPadding,
        cardCount: cardCount,
      );
    } else if (cardCount == 0) {
      _stackFocusedIndex = 0;
    } else {
      _scheduleCenterFocusedStackCard(
        topPadding: topPadding,
        cardCount: cardCount,
      );
    }
  }

  @override
  void didUpdateWidget(covariant SavedCardsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final cubit = context.read<SavedCardsCubit>();
    if (oldWidget.filterTrigger != widget.filterTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        cubit.requestOpenFilters();
      });
    }
    if (oldWidget.addCardTrigger != widget.addCardTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        cubit.requestAddCard();
      });
    }
  }

  void _openCardDetail(
    BuildContext context,
    SavedCard card, {
    String? heroTag,
  }) {
    openSavedCardDetail(
      context,
      card: card,
      heroTag: heroTag,
      getEventGroups: widget.getEventGroups,
      getSavedCards: widget.getSavedCards,
      updateEventGroup: widget.updateEventGroup,
      inviteEventGroupCardsByCardId: widget.inviteEventGroupCardsByCardId,
      getEventGroupOutboundInvitations:
          widget.getEventGroupOutboundInvitations,
      deleteEventGroup: widget.deleteEventGroup,
      linkSavedCardsToEventGroup: widget.linkSavedCardsToEventGroup,
      saveSavedCard: widget.saveSavedCard,
      deleteSavedCard: widget.deleteSavedCard,
      trackSavedCardContactClick: widget.trackSavedCardContactClick,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavedCardsCubit, SavedCardsState>(
      listener: (context, state) {
        final cubit = context.read<SavedCardsCubit>();
        handleSavedCardsStateChanges(
          context,
          state,
          addSavedCard: widget.addSavedCard,
          upgradeWalletPlan: widget.upgradeWalletPlan,
          restoreWalletPurchases: widget.restoreWalletPurchases,
          sourceCards: cubit.sourceCards,
        );
      },
      builder: (context, state) {
        final cubit = context.read<SavedCardsCubit>();
        final displayCards = cubit.displayCardsFor(cubit.sourceCards);
        const horizontalPadding = 20.0;
        const topPadding = 4.0;
        const contentBottomInset = 160.0;
        final quota = state.quota;
        final canAddMore = quota.canAddMore;

        _syncStackFocus(displayCards.length, topPadding: topPadding);

        if (displayCards.isNotEmpty &&
            (_lastCenteredFocusIndex != _stackFocusedIndex ||
                _lastCenteredCardCount != displayCards.length)) {
          _scheduleCenterFocusedStackCard(
            topPadding: topPadding,
            cardCount: displayCards.length,
          );
        }

        return CardenceScaffold(
          body: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: ColoredBox(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SavedCardsScreenToolbar(
                      searchQuery: state.searchQuery,
                      onSearchQueryChanged: cubit.setSearchQuery,
                      hasActiveFilters: state.hasActiveFilters,
                      hasActiveSearch: state.hasActiveSearch,
                      activeFilterCount: state.activeFilterCount,
                      onOpenFilters: cubit.requestOpenFilters,
                    ),
                    Expanded(
                      child: state.isLoadingCards
                          ? const SavedCardsLoadingShimmer()
                          : displayCards.isEmpty
                              ? SavedCardsEmptyResultsView(
                                  hasFilters: state.hasActiveFilters,
                                  hasSearch: state.hasActiveSearch,
                                  onClearFilters: cubit.clearFilters,
                                  onClearSearch: cubit.clearSearch,
                                )
                              : Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    SingleChildScrollView(
                                      controller: _stackScrollController,
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      padding: const EdgeInsets.fromLTRB(
                                        horizontalPadding,
                                        topPadding,
                                        horizontalPadding,
                                        contentBottomInset,
                                      ),
                                      child: SavedCardsCardStackView(
                                        displayCards: displayCards,
                                        focusedIndex: _stackFocusedIndex,
                                        onFocusedIndexChanged: (index) =>
                                            _setStackFocusedIndex(
                                          index,
                                          topPadding: topPadding,
                                          cardCount: displayCards.length,
                                        ),
                                        onOpenCard: (card, {heroTag}) =>
                                            _openCardDetail(
                                          context,
                                          card,
                                          heroTag: heroTag,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 2,
                                      top: 0,
                                      bottom: 0,
                                      child: Center(
                                        child: SavedCardsFocusArrowTrack(
                                          focusedIndex: _stackFocusedIndex,
                                          cardCount: displayCards.length,
                                          onFocusedIndexChanged: (index) =>
                                              _setStackFocusedIndex(
                                            index,
                                            topPadding: topPadding,
                                            cardCount: displayCards.length,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                  ],
                ),
                SavedCardsAddCardFab(
                  canAddMore: canAddMore,
                  onPressed: cubit.handleAddCardTap,
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }
}
