import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/delete_event_group.dart';
import '../../../event_groups/domain/usecases/link_event_group_cards.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../../domain/usecases/delete_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_state.dart';
import '../mixins/saved_cards_page_effects_mixin.dart';
import '../saved_cards_catalog.dart';
import '../widgets/saved_card_list_tile.dart';
import '../widgets/saved_cards_add_card_fab.dart';
import '../widgets/saved_cards_card_stack_view.dart';
import '../widgets/saved_cards_empty_results_view.dart';
import '../widgets/saved_cards_loading_shimmer.dart';
import '../widgets/saved_cards_screen_toolbar.dart';
import '../widgets/saved_cards_wallet_strip.dart';

/// Kaydettiği kişilerin kartları listesi (yalnızca görünüm katmanı).
class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({
    super.key,
    required this.showFlippableView,
    required this.filterTrigger,
    this.addCardTrigger = 0,
    required this.onViewModeChanged,
    required this.addSavedCard,
    required this.upgradeWalletPlan,
    required this.getEventGroups,
    required this.getSavedCards,
    required this.deleteEventGroup,
    required this.linkEventGroupCards,
    required this.saveSavedCard,
    required this.deleteSavedCard,
  });

  final bool showFlippableView;
  final int filterTrigger;
  final int addCardTrigger;
  final ValueChanged<bool> onViewModeChanged;
  final AddSavedCard addSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;
  final GetEventGroups getEventGroups;
  final GetSavedCards getSavedCards;
  final DeleteEventGroup deleteEventGroup;
  final LinkEventGroupCards linkEventGroupCards;
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
                    hasActiveFilters: state.hasActiveFilters,
                    activeFilterCount: state.activeFilterCount,
                    onViewModeChanged: widget.onViewModeChanged,
                    onOpenFilters: cubit.requestOpenFilters,
                  ),
                  Expanded(
                    child: state.isLoadingCards
                        ? const SavedCardsLoadingShimmer()
                        : displayCards.isEmpty
                            ? SavedCardsEmptyResultsView(
                                hasFilters: state.hasActiveFilters,
                                onClearFilters: cubit.clearFilters,
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
                                        linkEventGroupCards:
                                            widget.linkEventGroupCards,
                                        saveSavedCard: widget.saveSavedCard,
                                        deleteSavedCard: widget.deleteSavedCard,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      4,
                                      20,
                                      contentBottomInset,
                                    ),
                                    itemCount: displayCards.length,
                                    itemBuilder: (context, index) {
                                      final card = displayCards[index];
                                      return SavedCardListTile(
                                        card: card,
                                        onTap: () => openSavedCardDetail(
                                          context,
                                          card: card,
                                          getEventGroups: widget.getEventGroups,
                                          getSavedCards: widget.getSavedCards,
                                          deleteEventGroup: widget.deleteEventGroup,
                                        linkEventGroupCards:
                                            widget.linkEventGroupCards,
                                          saveSavedCard: widget.saveSavedCard,
                                          deleteSavedCard: widget.deleteSavedCard,
                                        ),
                                      );
                                    },
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
