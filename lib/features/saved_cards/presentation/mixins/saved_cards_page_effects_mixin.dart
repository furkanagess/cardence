import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_filter_models.dart';
import '../cubit/saved_cards_state.dart';
import '../widgets/add_saved_card_sheet.dart';
import '../widgets/saved_cards_filter_sheet.dart';
import '../wallet_paywall_flow.dart';
import '../pages/add_card_by_id_page.dart';
import '../pages/add_manual_card_page.dart';
import '../pages/scan_physical_card_page.dart';
import '../pages/saved_card_detail_page.dart';
import '../widgets/saved_cards_note_editor_sheet.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../../domain/usecases/delete_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/track_saved_card_contact_click.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
import '../../../ads/domain/usecases/show_post_add_card_monetization.dart';
import '../../../subscriptions/domain/usecases/restore_wallet_purchases.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/delete_event_group.dart';
import '../../domain/usecases/link_saved_cards_to_event_group.dart';

/// Kayıtlı kartlar sayfası yan etkileri: snackbar, sheet ve navigasyon.
mixin SavedCardsPageEffectsMixin<T extends StatefulWidget> on State<T> {
  void handleSavedCardsStateChanges(
    BuildContext context,
    SavedCardsState state, {
    required AddSavedCard addSavedCard,
    required UpgradeWalletPlan upgradeWalletPlan,
    required RestoreWalletPurchases restoreWalletPurchases,
    required ShowPostAddCardMonetization showPostAddCardMonetization,
    required List<SavedCard> sourceCards,
  }) {
    switch (state.effectType) {
      case SavedCardsEffectType.none:
        break;
      case SavedCardsEffectType.showSnackbar:
        final message = state.snackbarMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        context.read<SavedCardsCubit>().clearEffect();
      case SavedCardsEffectType.openFilters:
        _openFiltersSheet(context, sourceCards);
        context.read<SavedCardsCubit>().clearEffect();
      case SavedCardsEffectType.openAddCard:
        _openAddCardFlow(
          context,
          addSavedCard: addSavedCard,
          showPostAddCardMonetization: showPostAddCardMonetization,
          upgradeWalletPlan: upgradeWalletPlan,
          restoreWalletPurchases: restoreWalletPurchases,
        );
        context.read<SavedCardsCubit>().clearEffect();
      case SavedCardsEffectType.openUpgradeSheet:
        _openUpgradeSheet(
          context,
          upgradeWalletPlan: upgradeWalletPlan,
          restoreWalletPurchases: restoreWalletPurchases,
        );
        context.read<SavedCardsCubit>().clearEffect();
    }
  }

  Future<void> _openFiltersSheet(
    BuildContext context,
    List<SavedCard> sourceCards,
  ) async {
    final cubit = context.read<SavedCardsCubit>();
    final eventOptions = cubit.eventFilterOptionsForSource(context.l10n, sourceCards);

    var initialFilter = cubit.state.filter;
    if (!eventOptions.any((o) => o.value == initialFilter.eventFilter)) {
      initialFilter = initialFilter.copyWith(
        eventFilter: SavedCardsFilterSelection.allEventsValue,
      );
    }

    final result = await SavedCardsFilterSheet.show(
      context,
      initial: initialFilter,
      eventOptions: eventOptions,
      allEventsValue: SavedCardsFilterSelection.allEventsValue,
    );

    if (!context.mounted || result == null) return;
    cubit.applyFilter(result);
  }

  Future<void> _openAddCardFlow(
    BuildContext context, {
    required AddSavedCard addSavedCard,
    required ShowPostAddCardMonetization showPostAddCardMonetization,
    required UpgradeWalletPlan upgradeWalletPlan,
    required RestoreWalletPurchases restoreWalletPurchases,
  }) async {
    final cubit = context.read<SavedCardsCubit>();
    final quota = cubit.state.quota;

    final method = await AddSavedCardSheet.show(
      context,
      quota: quota,
      canAdd: quota.canAddMore,
      canAddManualSavedCard: quota.canAddManualSavedCard,
    );
    if (!context.mounted || method == null) return;

    if (method == AddSavedCardMethod.openPaywall) {
      await _openUpgradeSheet(
        context,
        upgradeWalletPlan: upgradeWalletPlan,
        restoreWalletPurchases: restoreWalletPurchases,
      );
      return;
    }

    AddSavedCardResult? result;
    switch (method) {
      case AddSavedCardMethod.openPaywall:
        return;
      case AddSavedCardMethod.manualEntry:
        result = await Navigator.of(context).push<AddSavedCardResult>(
          MaterialPageRoute(
            builder: (_) => AddManualCardPage(addSavedCard: addSavedCard),
          ),
        );
      case AddSavedCardMethod.physicalScan:
        result = await Navigator.of(context).push<AddSavedCardResult>(
          MaterialPageRoute(
            builder: (_) => ScanPhysicalCardPage(addSavedCard: addSavedCard),
          ),
        );
      case AddSavedCardMethod.cardId:
        result = await Navigator.of(context).push<AddSavedCardResult>(
          MaterialPageRoute(
            builder: (_) => AddCardByIdPage(addSavedCard: addSavedCard),
          ),
        );
    }

    if (!context.mounted) return;
    await cubit.handleAddCardResult(result);

    if (!context.mounted) return;
    if (result is AddSavedCardSuccess) {
      await showPostAddCardMonetization(
        showPaywall: () => _openUpgradeSheet(
          context,
          upgradeWalletPlan: upgradeWalletPlan,
          restoreWalletPurchases: restoreWalletPurchases,
        ),
      );
    }
  }

  Future<void> openSavedCardDetail(
    BuildContext context, {
    required SavedCard card,
    String? heroTag,
    required GetEventGroups getEventGroups,
    required GetSavedCards getSavedCards,
    required DeleteEventGroup deleteEventGroup,
    required LinkSavedCardsToEventGroup linkSavedCardsToEventGroup,
    required SaveSavedCard saveSavedCard,
    required DeleteSavedCard deleteSavedCard,
    required TrackSavedCardContactClick trackSavedCardContactClick,
  }) async {
    final cubit = context.read<SavedCardsCubit>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SavedCardDetailPage(
          card: card,
          heroTag: heroTag,
          getEventGroups: getEventGroups,
          getSavedCards: getSavedCards,
          deleteEventGroup: deleteEventGroup,
          linkSavedCardsToEventGroup: linkSavedCardsToEventGroup,
          saveSavedCard: saveSavedCard,
          deleteSavedCard: deleteSavedCard,
          trackSavedCardContactClick: trackSavedCardContactClick,
          onSave: cubit.persistCardUpdate,
        ),
      ),
    );
    if (!context.mounted) return;
    await cubit.refreshAll();
  }

  Future<void> openSavedCardNoteEditor(
    BuildContext context, {
    required SavedCard card,
  }) async {
    final cubit = context.read<SavedCardsCubit>();
    final note = await SavedCardsNoteEditorSheet.show(
      context,
      initialNote: card.note ?? '',
    );
    if (!context.mounted || note == null) return;
    await cubit.persistCardUpdate(
      card.copyWith(
        note: note.isEmpty ? null : note,
        clearNote: note.isEmpty,
      ),
    );
  }

  Future<void> _openUpgradeSheet(
    BuildContext context, {
    required UpgradeWalletPlan upgradeWalletPlan,
    required RestoreWalletPurchases restoreWalletPurchases,
  }) async {
    await WalletPaywallFlow.show(
      context,
      cubit: context.read<SavedCardsCubit>(),
    );
  }
}
