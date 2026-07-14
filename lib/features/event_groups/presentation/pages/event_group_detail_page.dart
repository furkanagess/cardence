import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/create_card_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/delete_saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/domain/usecases/save_saved_card.dart';
import '../../../saved_cards/presentation/pages/saved_card_detail_page.dart';
import '../../../network_graph/domain/entities/graph_scope.dart';
import '../../../network_graph/domain/usecases/get_network_graph.dart';
import '../../../network_graph/domain/usecases/get_network_graph_path.dart';
import '../../../network_graph/presentation/helpers/network_graph_launcher.dart';
import '../../domain/entities/event_group.dart';
import '../../domain/entities/event_group_update_input.dart';
import '../../domain/usecases/get_event_groups.dart';
import '../../domain/usecases/delete_event_group.dart';
import '../../domain/usecases/update_event_group.dart';
import '../../domain/usecases/invite_event_group_cards_by_card_id.dart';
import '../../domain/usecases/get_event_group_outbound_invitations.dart';
import '../../../saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import '../../domain/entities/event_group_outbound_invitation.dart';
import '../widgets/event_group_detail_header.dart';
import '../widgets/event_group_detail_invited_section.dart';
import '../widgets/event_group_detail_linked_cards_section.dart';
import '../widgets/event_group_detail_loading_shimmer.dart';
import '../widgets/pick_saved_cards_for_group_sheet.dart';
import '../widgets/invite_event_group_cards_sheet.dart';
import '../widgets/edit_event_group_sheet.dart';

/// Bir etkinlik grubunun detayı: kapak, meta ve gruptaki kartlar.
class EventGroupDetailPage extends StatefulWidget {
  const EventGroupDetailPage({
    super.key,
    required this.group,
    required this.getEventGroups,
    required this.updateEventGroup,
    required this.inviteEventGroupCardsByCardId,
    required this.getEventGroupOutboundInvitations,
    required this.deleteEventGroup,
    required this.linkSavedCardsToEventGroup,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.deleteSavedCard,
    this.getNetworkGraph,
    this.getNetworkGraphPath,
    this.onSavedCardsChanged,
  });

  final EventGroup group;
  final GetEventGroups getEventGroups;
  final UpdateEventGroup updateEventGroup;
  final InviteEventGroupCardsByCardId inviteEventGroupCardsByCardId;
  final GetEventGroupOutboundInvitations getEventGroupOutboundInvitations;
  final DeleteEventGroup deleteEventGroup;
  final LinkSavedCardsToEventGroup linkSavedCardsToEventGroup;
  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final DeleteSavedCard deleteSavedCard;
  final GetNetworkGraph? getNetworkGraph;
  final GetNetworkGraphPath? getNetworkGraphPath;
  final Future<void> Function()? onSavedCardsChanged;

  @override
  State<EventGroupDetailPage> createState() => _EventGroupDetailPageState();
}

class _EventGroupDetailPageState extends State<EventGroupDetailPage> {
  late EventGroup _group;
  List<SavedCard> _linkedCards = [];
  List<SavedCard> _availableToAdd = [];
  List<EventGroupOutboundInvitation> _outboundInvitations = [];
  bool _loadingLinkedCards = false;
  bool _loadingInvitations = false;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _load();
  }

  Future<void> _load() async {
    if (_initialLoading && mounted) {
      setState(() {
        _loadingLinkedCards = true;
        _loadingInvitations = true;
      });
    }
    final groupsFuture = widget.getEventGroups();
    final cardsFuture = widget.getSavedCards();
    final invitationsFuture = _fetchOutboundInvitations();

    final groups = await groupsFuture;
    final cards = await cardsFuture;
    final invitations = await invitationsFuture;

    if (!mounted) return;
    EventGroup? refreshedGroup;
    for (final group in groups) {
      if (group.id == _group.id) {
        refreshedGroup = group;
        break;
      }
    }
    setState(() {
      if (refreshedGroup != null) {
        _group = refreshedGroup;
      }
      _linkedCards = cards
          .where((c) => c.linkedEventGroupIds.contains(_group.id))
          .toList();
      _availableToAdd = cards
          .where((c) => !c.linkedEventGroupIds.contains(_group.id))
          .toList();
      if (invitations != null) {
        _outboundInvitations = invitations;
      }
      _loadingLinkedCards = false;
      _loadingInvitations = false;
      _initialLoading = false;
    });
  }

  /// Null = istek başarısız; mevcut liste korunur.
  Future<List<EventGroupOutboundInvitation>?> _fetchOutboundInvitations() async {
    try {
      return await widget.getEventGroupOutboundInvitations(_group.id);
    } catch (_) {
      return null;
    }
  }

  Future<void> _refreshOutboundInvitations() async {
    if (!mounted) return;
    setState(() => _loadingInvitations = true);
    final invitations = await _fetchOutboundInvitations();
    if (!mounted) return;
    setState(() {
      if (invitations != null) {
        _outboundInvitations = invitations;
      }
      _loadingInvitations = false;
    });
  }

  Future<void> _persistCardUpdate(SavedCard updated) async {
    await widget.saveSavedCard(updated);
    await _load();
  }

  Future<void> _openCardDetail(SavedCard card, {String? heroTag}) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SavedCardDetailPage(
          card: card,
          heroTag: heroTag,
          getEventGroups: widget.getEventGroups,
          getSavedCards: widget.getSavedCards,
          updateEventGroup: widget.updateEventGroup,
          inviteEventGroupCardsByCardId: widget.inviteEventGroupCardsByCardId,
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

  Future<void> _openInviteByCardId() async {
    final result = await InviteEventGroupCardsSheet.show(
      context,
      onSendInvites: (cardIds) => widget.inviteEventGroupCardsByCardId(
        groupId: _group.id,
        cardIds: cardIds,
      ),
    );
    if (!mounted || result == null) return;

    setState(() => _group = result.group);
    // Davet gönderildikten hemen sonra listeyi yenile (bağlı kartlar ayrı yüklenir).
    await _refreshOutboundInvitations();
    await widget.onSavedCardsChanged?.call();
    if (!mounted) return;
    await _load();
  }

  Future<void> _openAddCardsPicker() async {
    final inviteable = _availableToAdd
        .where((card) => !card.isManualEntry)
        .toList(growable: false);

    if (inviteable.isEmpty) {
      await _openInviteByCardId();
      return;
    }

    final selectedIds = await PickSavedCardsForGroupSheet.show(
      context,
      cards: inviteable,
      eventGroupId: _group.id,
      eventGroupName: _group.name,
      addOnly: true,
    );
    if (!mounted || selectedIds == null || selectedIds.isEmpty) return;

    final updated = await widget.inviteEventGroupCardsByCardId(
      groupId: _group.id,
      cardIds: selectedIds.toList(),
    );
    if (!mounted) return;

    setState(() => _group = updated);
    await _refreshOutboundInvitations();
    await widget.onSavedCardsChanged?.call();
    if (!mounted) return;
    await _load();
  }

  Future<void> _openEditSheet() async {
    final groups = await widget.getEventGroups();
    if (!mounted) return;
    final existingNames = groups
        .where((group) => group.id != _group.id)
        .map((group) => group.name)
        .toList();

    final result = await EditEventGroupSheet.show(
      context,
      group: _group,
      existingNames: existingNames,
    );
    if (!mounted || result == null) return;

    final updated = await widget.updateEventGroup(
      EventGroupUpdateInput(
        id: _group.id,
        name: result.name,
        location: result.location,
        startAt: result.startAt,
        endAt: result.endAt,
        description: result.description,
        photoFilePath: result.photoFilePath,
        clearPhoto: result.clearPhoto,
      ),
    );
    if (!mounted) return;
    setState(() => _group = updated);
    await _load();
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
      eventGroupId: _group.id,
      eventGroupName: _group.name,
    );
  }

  Future<void> _confirmDeleteGroup() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppL10n.grubuSil(l10n)),
        content: Text(
          '${AppL10n.deleteEventGroupConfirmMessage(l10n, _group.name)}\n'
          '${AppL10n.deleteEventGroupConfirmSubMessage(l10n)}',
        ),
        actions: [
          CustomButton.text(
            label: AppL10n.iptal(l10n),
            onPressed: () => Navigator.of(context).pop(false),
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
    await widget.deleteEventGroup(_group.id);
    await widget.getSavedCards();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _onMenuSelected(String value) async {
    switch (value) {
      case 'edit':
        await _openEditSheet();
      case 'invite':
        await _openInviteByCardId();
      case 'network':
        await _openNetworkGraph();
      case 'delete':
        await _confirmDeleteGroup();
    }
  }

  Widget _buildCardsSection(BuildContext context) {
    if (_loadingLinkedCards) {
      return const EventGroupDetailCardsSectionShimmer();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_linkedCards.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: eventGroupDetailPanelHorizontalPadding,
        ),
        child: Column(
          children: [
            Text(
              context.l10n.noCardsInGroup,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            CreateCardButton(
              label: AppL10n.kartEkle(context.l10n),
              onTap: _openAddCardsPicker,
            ),
          ],
        ),
      );
    }

    return EventGroupDetailLinkedCardsSection(
      cards: _linkedCards,
      onOpenCard: (card, {heroTag}) => _openCardDetail(card, heroTag: heroTag),
    );
  }

  Widget _buildBody(BuildContext context) {
    final coverHeight = eventGroupDetailCoverHeight(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: coverHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  EventGroupDetailCover(group: _group),
                  Positioned.fill(
                    child: EventGroupDetailHeroOverlay(
                      group: _group,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: EventGroupDetailScrollPanel(
                bottomPadding: bottomInset + 16,
                child: EventGroupDetailScrollContent(
                  group: _group,
                  linkedCardCount: _linkedCards.length,
                  inviteCount: _outboundInvitations
                      .where((invite) => invite.isPending)
                      .length,
                  loadingLinkedCards: _loadingLinkedCards,
                  onAddCard: _loadingLinkedCards ? null : _openAddCardsPicker,
                  invitedSection: EventGroupDetailInvitedSection(
                    key: ValueKey(
                      'outbound-${_outboundInvitations.length}-'
                      '${_outboundInvitations.map((e) => e.id).join(',')}',
                    ),
                    invitations: _outboundInvitations,
                    isLoading: _loadingInvitations,
                  ),
                  cardsSection: _buildCardsSection(context),
                ),
              ),
            ),
          ],
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                EventGroupDetailOverlayIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: context.l10n.geri,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                if (widget.getNetworkGraph != null &&
                    widget.getNetworkGraphPath != null) ...[
                  EventGroupDetailOverlayIconButton(
                    icon: Icons.hub_outlined,
                    tooltip: context.l10n.viewEventNetwork,
                    onPressed: _openNetworkGraph,
                  ),
                  const SizedBox(width: 8),
                ],
                PopupMenuButton<String>(
                  color: colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: _onMenuSelected,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(context.l10n.duzenle),
                    ),
                    PopupMenuItem(
                      value: 'invite',
                      child: Text(context.l10n.eventInviteCardsTitle),
                    ),
                    if (widget.getNetworkGraph != null &&
                        widget.getNetworkGraphPath != null)
                      PopupMenuItem(
                        value: 'network',
                        child: Text(context.l10n.viewEventNetwork),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        AppL10n.buGrubuSil(context.l10n),
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                  child: Material(
                    color: AppColors.textPrimary.withValues(alpha: 0.28),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CardenceScaffold(
      showWatermark: false,
      body: _buildBody(context),
    );
  }
}
