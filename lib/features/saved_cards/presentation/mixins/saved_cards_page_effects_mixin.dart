import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../cubit/saved_cards_cubit.dart';
import '../cubit/saved_cards_filter_models.dart';
import '../cubit/saved_cards_state.dart';
import '../widgets/add_saved_card_sheet.dart';
import '../widgets/saved_cards_filter_sheet.dart';
import '../widgets/wallet_upgrade_sheet.dart';
import '../pages/add_card_by_id_page.dart';
import '../pages/add_manual_card_page.dart';
import '../pages/scan_physical_card_page.dart';
import '../pages/saved_card_detail_page.dart';
import '../widgets/saved_cards_note_editor_sheet.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../../domain/usecases/delete_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
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
        _openAddCardFlow(context, addSavedCard: addSavedCard);
        context.read<SavedCardsCubit>().clearEffect();
      case SavedCardsEffectType.openUpgradeSheet:
        _openUpgradeSheet(context, upgradeWalletPlan: upgradeWalletPlan);
        context.read<SavedCardsCubit>().clearEffect();
    }
  }

  Future<void> _openFiltersSheet(
    BuildContext context,
    List<SavedCard> sourceCards,
  ) async {
    final cubit = context.read<SavedCardsCubit>();
    final eventOptions = cubit.eventFilterOptionsForSource(sourceCards);

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
  }) async {
    final cubit = context.read<SavedCardsCubit>();
    final quota = cubit.state.quota;
    if (quota == null) return;

    final method = await AddSavedCardSheet.show(
      context,
      quota: quota,
      canAdd: quota.canAddMore,
    );
    if (!context.mounted || method == null) return;

    AddSavedCardResult? result;
    switch (method) {
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
  }) async {
    final cubit = context.read<SavedCardsCubit>();
    if (cubit.state.draggingCardIndex != null) return;

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
  }) async {
    final cubit = context.read<SavedCardsCubit>();
    final upgraded = await WalletUpgradeSheet.show(
      context,
      upgradeWalletPlan: upgradeWalletPlan,
    );
    if (!context.mounted) return;
    if (upgraded == true) {
      await cubit.upgradeWallet();
    } else {
      await cubit.refreshAll();
    }
  }
}
