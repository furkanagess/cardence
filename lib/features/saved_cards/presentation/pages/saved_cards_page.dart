import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/delete_event_group.dart';
import '../../domain/usecases/link_saved_cards_to_event_group.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../../domain/usecases/delete_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
import '../../../subscriptions/domain/usecases/restore_wallet_purchases.dart';
import '../../../ads/domain/usecases/show_post_add_card_monetization.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_state.dart';
import '../mixins/saved_cards_page_effects_mixin.dart';
import '../saved_cards_catalog.dart';
import '../widgets/saved_card_list_tile.dart';
import '../widgets/saved_cards_add_card_fab.dart';
import '../widgets/saved_cards_card_stack_view.dart';
import '../widgets/saved_cards_empty_results_view.dart';
import '../widgets/saved_cards_list_header.dart';
import '../widgets/saved_cards_loading_shimmer.dart';
import '../widgets/saved_cards_screen_toolbar.dart';
import '../widgets/saved_cards_wallet_strip.dart';

/// Kaydettiği kişilerin kartları listesi (yalnızca görünüm katmanı).
class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({
    super.key,
    required this.showFlippableView,
    required this.onViewModeChanged,
    required this.filterTrigger,
    this.addCardTrigger = 0,
    required this.addSavedCard,
    required this.upgradeWalletPlan,
    required this.restoreWalletPurchases,
    required this.showPostAddCardMonetization,
    required this.getEventGroups,
    required this.getSavedCards,
    required this.deleteEventGroup,
    required this.linkSavedCardsToEventGroup,
    required this.saveSavedCard,
    required this.deleteSavedCard,
  });

  final bool showFlippableView;
  final ValueChanged<bool> onViewModeChanged;
  final int filterTrigger;
  final int addCardTrigger;
  final AddSavedCard addSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;
  final RestoreWalletPurchases restoreWalletPurchases;
  final ShowPostAddCardMonetization showPostAddCardMonetization;
  final GetEventGroups getEventGroups;
  final GetSavedCards getSavedCards;
  final DeleteEventGroup deleteEventGroup;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final SaveSavedCard saveSavedCard;
  final DeleteSavedCard deleteSavedCard;

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage>
    with SavedCardsPageEffectsMixin {
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
          showPostAddCardMonetization: widget.showPostAddCardMonetization,
          sourceCards: cubit.sourceCards,
        );
      },
      builder: (context, state) {
        final cubit = context.read<SavedCardsCubit>();
        final useDummyCards = SavedCardsCatalog.isUsingDemoCards(state.cards);
        final displayCards = cubit.displayCardsFor(cubit.sourceCards);
        const horizontalPadding = 20.0;
        const topPadding = 4.0;
        const contentBottomInset = 128.0;
        final quota = state.quota;
        final canAddMore = quota?.canAddMore ?? true;
        final isDemoMode = useDummyCards;

        return CardenceScaffold(
          body: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SafeArea(
                    bottom: false,
                    child: quota != null
                        ? SavedCardsWalletStrip(
                            quota: quota,
                            isDemoMode: isDemoMode,
                            onUpgradeTap: cubit.requestUpgradeSheet,
                          )
                        : const SavedCardsWalletStripShimmer(),
                  ),
                  SavedCardsScreenToolbar(
                    showFlippableView: widget.showFlippableView,
                    onViewModeChanged: widget.onViewModeChanged,
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
                            : widget.showFlippableView
                                ? SingleChildScrollView(
                                    padding: const EdgeInsets.fromLTRB(
                                      horizontalPadding,
                                      topPadding,
                                      horizontalPadding,
                                      contentBottomInset,
                                    ),
                                    child: SavedCardsCardStackView(
                                      displayCards: displayCards,
                                      state: state,
                                      cubit: cubit,
                                      useDummyCards: useDummyCards,
                                      onOpenCard: (card, {heroTag}) =>
                                          openSavedCardDetail(
                                        context,
                                        card: card,
                                        heroTag: heroTag,
                                        getEventGroups: widget.getEventGroups,
                                        getSavedCards: widget.getSavedCards,
                                        deleteEventGroup: widget.deleteEventGroup,
                                        linkSavedCardsToEventGroup:
                                            widget.linkSavedCardsToEventGroup,
                                        saveSavedCard: widget.saveSavedCard,
                                        deleteSavedCard: widget.deleteSavedCard,
                                      ),
                                    ),
                                  )
                                : CustomScrollView(
                                    slivers: [
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                          horizontalPadding,
                                          topPadding,
                                          horizontalPadding,
                                          0,
                                        ),
                                        sliver: SliverToBoxAdapter(
                                          child: SavedCardsListHeader(
                                            count: displayCards.length,
                                          ),
                                        ),
                                      ),
                                      SliverPadding(
                                        padding: const EdgeInsets.fromLTRB(
                                          horizontalPadding,
                                          0,
                                          horizontalPadding,
                                          contentBottomInset,
                                        ),
                                        sliver: SliverList(
                                          delegate: SliverChildBuilderDelegate(
                                            (context, index) {
                                              final card = displayCards[index];
                                              return SavedCardListTile(
                                                card: card,
                                                onTap: () => openSavedCardDetail(
                                                  context,
                                                  card: card,
                                                  getEventGroups:
                                                      widget.getEventGroups,
                                                  getSavedCards:
                                                      widget.getSavedCards,
                                                  deleteEventGroup:
                                                      widget.deleteEventGroup,
                                                  linkSavedCardsToEventGroup:
                                                      widget
                                                          .linkSavedCardsToEventGroup,
                                                  saveSavedCard:
                                                      widget.saveSavedCard,
                                                  deleteSavedCard:
                                                      widget.deleteSavedCard,
                                                ),
                                              );
                                            },
                                            childCount: displayCards.length,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                  ),
                ],
              ),
              Positioned.fill(
                child: SavedCardsDraggableFab(
                  canAddMore: canAddMore,
                  onPressed: cubit.handleAddCardTap,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
