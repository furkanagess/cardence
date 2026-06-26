import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/extensions/saved_card_preview_colors.dart';
import '../../../saved_cards/domain/extensions/saved_card_preview_entries.dart';
import '../../../saved_cards/domain/usecases/delete_saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/domain/usecases/save_saved_card.dart';
import '../../../saved_cards/presentation/pages/saved_card_detail_page.dart';
import '../../../network_graph/domain/entities/graph_scope.dart';
import '../../../network_graph/domain/usecases/get_network_graph.dart';
import '../../../network_graph/domain/usecases/get_network_graph_path.dart';
import '../../../network_graph/presentation/helpers/network_graph_launcher.dart';
import '../../domain/entities/event_group.dart';
import '../../domain/usecases/get_event_groups.dart';
import '../../domain/usecases/delete_event_group.dart';
import '../../../saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import '../widgets/event_group_info_banner.dart';
import '../widgets/pick_saved_cards_for_group_sheet.dart';

/// Bir etkinlik grubunun detayı: bu gruba bağlı kayıtlı kartlar listelenir.
class EventGroupDetailPage extends StatefulWidget {
  const EventGroupDetailPage({
    super.key,
    required this.group,
    required this.getEventGroups,
    required this.deleteEventGroup,
    required this.linkSavedCardsToEventGroup,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.deleteSavedCard,
    this.getNetworkGraph,
    this.getNetworkGraphPath,
  });

  final EventGroup group;
  final GetEventGroups getEventGroups;
  final DeleteEventGroup deleteEventGroup;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final GetNetworkGraph? getNetworkGraph;
  final GetNetworkGraphPath? getNetworkGraphPath;

  @override
  State<EventGroupDetailPage> createState() => _EventGroupDetailPageState();
}

class _EventGroupDetailPageState extends State<EventGroupDetailPage> {
  List<SavedCard> _linkedCards = [];
  List<SavedCard> _availableToAdd = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final cards = await widget.getSavedCards();
    if (!mounted) return;
    final allCards = cards;
    setState(() {
      _linkedCards = allCards
          .where((c) => c.linkedEventGroupIds.contains(widget.group.id))
          .toList();
      _availableToAdd = allCards
          .where((c) => !c.linkedEventGroupIds.contains(widget.group.id))
          .toList();
      _loading = false;
    });
  }

  Future<void> _persistCardUpdate(SavedCard updated) async {
    await widget.saveSavedCard(updated);
    await _load();
  }

  Future<void> _openCardDetail(SavedCard card) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SavedCardDetailPage(
          card: card,
          getEventGroups: widget.getEventGroups,
          getSavedCards: widget.getSavedCards,
          deleteEventGroup: widget.deleteEventGroup,
          linkSavedCardsToEventGroup: widget.linkSavedCardsToEventGroup,
          saveSavedCard: widget.saveSavedCard,
          deleteSavedCard: widget.deleteSavedCard,
          onSave: _persistCardUpdate,
        ),
      ),
    );
    await _load();
  }

  Future<void> _openAddCardsPicker() async {
    if (_availableToAdd.isEmpty) {
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppL10n.grubaEklenecekKaytlKartKalmad(l10n)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedIds = await PickSavedCardsForGroupSheet.show(
      context,
      cards: _availableToAdd,
      eventGroupId: widget.group.id,
      eventGroupName: widget.group.name,
      addOnly: true,
    );
    if (!mounted || selectedIds == null || selectedIds.isEmpty) return;

    final allCards = await widget.getSavedCards();
    await widget.linkSavedCardsToEventGroup(
      groupId: widget.group.id,
      allCards: allCards,
      cardIdsToAdd: selectedIds.toList(),
    );
    final addedCount = selectedIds.length;
    await widget.getSavedCards();

    if (!mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppL10n.cardsAddedToGroupMessage(context.l10n, addedCount)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openNetworkGraph() async {
    final getNetworkGraph = widget.getNetworkGraph;
    final getNetworkGraphPath = widget.getNetworkGraphPath;
    if (getNetworkGraph == null || getNetworkGraphPath == null) return;

    await NetworkGraphLauncher.open(
      context,
      getNetworkGraph: getNetworkGraph,
      getNetworkGraphPath: getNetworkGraphPath,
      getEventGroups: widget.getEventGroups,
      initialScope: GraphScope.event,
      eventGroupId: widget.group.id,
      eventGroupName: widget.group.name,
    );
  }

  Future<void> _confirmDeleteGroup() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppL10n.grubuSil(l10n)),
        content: Text(
          '${AppL10n.deleteEventGroupConfirmMessage(l10n, widget.group.name)}\n'
          '${AppL10n.deleteEventGroupConfirmSubMessage(l10n)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppL10n.iptal(l10n)),
          ),
          CustomButton(
            label: AppL10n.sil(l10n),
            onPressed: () => Navigator.of(context).pop(true),
            fullWidth: false,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _deleteGroup();
  }

  Future<void> _deleteGroup() async {
    await widget.deleteEventGroup(widget.group.id);
    await widget.getSavedCards();

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppL10n.eventGroupDeletedMessage(context.l10n, widget.group.name)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openAddNoteModal(SavedCard card) async {
    var draftNote = card.note ?? '';
    final note = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                final l10n = context.l10n;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppL10n.kiiNotu(l10n),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: draftNote,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 240,
                      onChanged: (value) =>
                          setModalState(() => draftNote = value),
                      decoration: InputDecoration(
                        hintText: AppL10n.buKiiHakkndaNotYazn(l10n),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      label: AppL10n.kaydet(l10n),
                      onPressed: () =>
                          Navigator.of(context).pop(draftNote.trim()),
                      fullWidth: false,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted || note == null) return;
    await _persistCardUpdate(
      card.copyWith(
        note: note.isEmpty ? null : note,
        clearNote: note.isEmpty,
      ),
    );
  }

  static const double _deleteBarContentHeight = 48;
  static const double _deleteBarVerticalPadding = 16;

  double _deleteBarInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom +
        _deleteBarVerticalPadding +
        _deleteBarContentHeight +
        _deleteBarVerticalPadding;
  }

  Widget _buildStickyDeleteBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          _deleteBarVerticalPadding,
        ),
        child: Material(
          color: Colors.transparent,
          child: CustomButton(
            label: AppL10n.buGrubuSil(context.l10n),
            icon: Icons.delete_outline_rounded,
            onPressed: _confirmDeleteGroup,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 8,
              shadowColor: AppColors.error.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final bottomInset = _deleteBarInset(context);

    if (_linkedCards.isEmpty) {
      return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
        child: Column(
          children: [
            EventGroupInfoBanner(group: widget.group),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.sizeOf(context).height -
                      (MediaQuery.paddingOf(context).top + kToolbarHeight) -
                      bottomInset -
                      120,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
              Icon(
                Icons.credit_card_off_rounded,
                size: 64,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                AppL10n.buGruptaKartYok(context.l10n),
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                AppL10n.kaydedilenKartlarnzdanSeerekBuGruba(context.l10n),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: AppL10n.kartEkle(context.l10n),
                icon: Icons.add_rounded,
                onPressed: _availableToAdd.isEmpty ? null : _openAddCardsPicker,
                fullWidth: false,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(0, 0, 0, bottomInset),
      itemCount: _linkedCards.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return EventGroupInfoBanner(group: widget.group);
        }

        final card = _linkedCards[index - 1];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: _SavedCardPreviewTile(
            card: card,
            onTap: () => _openCardDetail(card),
            onAddNote: () => _openAddNoteModal(card),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return CardenceScaffold(
      appBar: CardenceAppBar(
        title: widget.group.name,
        actions: [
          if (widget.getNetworkGraph != null &&
              widget.getNetworkGraphPath != null)
            CardenceAppBar.iconAction(
              icon: Icons.hub_outlined,
              tooltip: AppL10n.viewEventNetwork(context.l10n),
              onPressed: _openNetworkGraph,
            ),
          if (!_loading && _availableToAdd.isNotEmpty)
            CardenceAppBar.iconAction(
              icon: Icons.person_add_alt_1_rounded,
              tooltip: AppL10n.kartEkle(context.l10n),
              onPressed: _openAddCardsPicker,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                _buildBodyContent(context, colorScheme, textTheme),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildStickyDeleteBar(context),
                ),
              ],
            ),
    );
  }
}

class _SavedCardPreviewTile extends StatelessWidget {
  const _SavedCardPreviewTile({
    required this.card,
    required this.onTap,
    this.onAddNote,
  });

  final SavedCard card;
  final VoidCallback onTap;
  final VoidCallback? onAddNote;

  @override
  Widget build(BuildContext context) {
    final displayName = card.displayName?.trim().isEmpty ?? true
        ? 'Kart ${card.cardId}'
        : card.displayName!;
    final companyName = card.company?.trim();

    final visibleContacts = <String>[
      if (card.email != null && card.email!.trim().isNotEmpty) 'email',
      if (card.phone != null && card.phone!.trim().isNotEmpty) 'phone',
      if (card.linkedin != null && card.linkedin!.trim().isNotEmpty) 'linkedin',
      if (card.website != null && card.website!.trim().isNotEmpty) 'website',
    ];

    return GestureDetector(
      onTap: onTap,
      child: FlippablePersonCard(
        title: displayName,
        titleSecondary: companyName,
        jobTitle: card.title?.trim(),
        photoUrl: card.photoUrl,
        accentColor: card.previewAccentColor,
        backgroundColor: card.previewBackgroundColor,
        frontEntries: const [],
        backEntries: card.backAboutEntries,
        emptyMessage: AppL10n.kartBilgisiYok(context.l10n),
        cardId: card.cardId,
        onTap: onTap,
        contactEmail: card.email,
        contactPhone: card.phone,
        contactWebsite: card.website,
        contactLinkedin: card.linkedin,
        visibleContactFields: visibleContacts,
      ),
    );
  }
}
