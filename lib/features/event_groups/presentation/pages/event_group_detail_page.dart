import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../saved_cards/domain/entities/saved_card.dart';
import '../../../saved_cards/domain/usecases/delete_saved_card.dart';
import '../../../saved_cards/domain/usecases/get_saved_cards.dart';
import '../../../saved_cards/domain/usecases/save_saved_card.dart';
import '../../../saved_cards/presentation/pages/saved_card_detail_page.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_focus_arrow_track.dart';
import '../../../saved_cards/presentation/widgets/saved_cards_horizontal_stack_view.dart';
import '../../../network_graph/domain/entities/graph_scope.dart';
import '../../../network_graph/domain/usecases/get_network_graph.dart';
import '../../../network_graph/domain/usecases/get_network_graph_path.dart';
import '../../../network_graph/presentation/helpers/network_graph_launcher.dart';
import '../../domain/entities/event_group.dart';
import '../../domain/usecases/get_event_groups.dart';
import '../../domain/usecases/delete_event_group.dart';
import '../../domain/usecases/update_event_group.dart';
import '../../domain/usecases/invite_event_group_cards_by_card_id.dart';
import '../../../saved_cards/domain/usecases/link_saved_cards_to_event_group.dart';
import '../widgets/event_group_detail_header.dart';
import '../widgets/event_group_detail_loading_shimmer.dart';
import '../widgets/pick_saved_cards_for_group_sheet.dart';
import '../widgets/invite_event_group_cards_sheet.dart';

/// Bir etkinlik grubunun detayı: bu gruba bağlı kayıtlı kartlar listelenir.
class EventGroupDetailPage extends StatefulWidget {
  const EventGroupDetailPage({
    super.key,
    required this.group,
    required this.getEventGroups,
    required this.updateEventGroup,
    required this.inviteEventGroupCardsByCardId,
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
  bool _loading = true;
  bool _aboutExpanded = false;
  int _focusedCardIndex = 0;
  double _cardWidth = 280;
  bool _isProgrammaticScroll = false;
  late final ScrollController _cardsScrollController;

  static const double _cardsHorizontalPadding = 20;

  @override
  void initState() {
    super.initState();
    _group = widget.group;
    _cardsScrollController = ScrollController();
    _load();
  }

  @override
  void dispose() {
    _cardsScrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final groups = await widget.getEventGroups();
    final cards = await widget.getSavedCards();
    if (!mounted) return;
    EventGroup? refreshedGroup;
    for (final group in groups) {
      if (group.id == _group.id) {
        refreshedGroup = group;
        break;
      }
    }
    final allCards = cards;
    setState(() {
      if (refreshedGroup != null) {
        _group = refreshedGroup;
      }
      _linkedCards = allCards
          .where((c) => c.linkedEventGroupIds.contains(_group.id))
          .toList();
      _availableToAdd = allCards
          .where((c) => !c.linkedEventGroupIds.contains(_group.id))
          .toList();
      if (_linkedCards.isEmpty) {
        _focusedCardIndex = 0;
      } else if (_focusedCardIndex >= _linkedCards.length) {
        _focusedCardIndex = _linkedCards.length - 1;
      }
      _loading = false;
    });
    if (_linkedCards.isNotEmpty) {
      _scheduleCenterFocusedCard();
    }
  }

  void _setFocusedCardIndex(int index, {bool animateScroll = true}) {
    if (_linkedCards.isEmpty) return;
    final next = index.clamp(0, _linkedCards.length - 1);
    if (next == _focusedCardIndex) {
      if (animateScroll) _scheduleCenterFocusedCard();
      return;
    }
    setState(() => _focusedCardIndex = next);
    if (animateScroll) _scheduleCenterFocusedCard();
  }

  /// Viewport ortasına en yakın kartın index'ini bulur.
  int _nearestCardIndexToViewportCenter() {
    if (!_cardsScrollController.hasClients || _linkedCards.isEmpty) {
      return _focusedCardIndex;
    }

    final position = _cardsScrollController.position;
    final viewportCenter =
        position.pixels + position.viewportDimension / 2;
    var bestIndex = 0;
    var bestDistance = double.infinity;

    for (var i = 0; i < _linkedCards.length; i++) {
      final left = _cardsHorizontalPadding +
          SavedCardsHorizontalStackView.cardLeftForIndex(
            i,
            _focusedCardIndex,
            _cardWidth,
          );
      final cardCenter = left + (_cardWidth / 2);
      final distance = (cardCenter - viewportCenter).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  void _syncFocusedIndexFromScroll() {
    final nearest = _nearestCardIndexToViewportCenter();
    if (nearest == _focusedCardIndex) return;
    _setFocusedCardIndex(nearest, animateScroll: false);
  }

  void _scheduleCenterFocusedCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _centerFocusedCard();
    });
  }

  Future<void> _centerFocusedCard() async {
    if (!_cardsScrollController.hasClients || _linkedCards.isEmpty) return;
    final target = SavedCardsHorizontalStackView.cardLeftForIndex(
      _focusedCardIndex,
      _focusedCardIndex,
      _cardWidth,
    );
    final max = _cardsScrollController.position.maxScrollExtent;
    _isProgrammaticScroll = true;
    try {
      await _cardsScrollController.animateTo(
        target.clamp(0.0, max),
        duration: SavedCardsHorizontalStackView.stackAnimDuration,
        curve: SavedCardsHorizontalStackView.stackAnimCurve,
      );
    } finally {
      if (mounted) _isProgrammaticScroll = false;
    }
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

    if (result.invitedCount > 0) {
      await widget.onSavedCardsChanged?.call();
      await _load();
    }

    setState(() => _group = result.group);
  }

  Future<void> _openAddCardsPicker() async {
    if (_availableToAdd.isEmpty) {
      return;
    }

    final selectedIds = await PickSavedCardsForGroupSheet.show(
      context,
      cards: _availableToAdd,
      eventGroupId: _group.id,
      eventGroupName: _group.name,
      addOnly: true,
    );
    if (!mounted || selectedIds == null || selectedIds.isEmpty) return;

    final allCards = await widget.getSavedCards();
    await widget.linkSavedCardsToEventGroup(
      groupId: _group.id,
      allCards: allCards,
      cardIdsToAdd: selectedIds.toList(),
    );
    await widget.getSavedCards();

    if (!mounted) return;
    await _load();
    if (!mounted) return;
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

  void _onAddCardPressed() {
    if (_availableToAdd.isNotEmpty) {
      _openAddCardsPicker();
      return;
    }
    _openInviteByCardId();
  }

  Widget _buildBody(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final coverHeight = eventGroupDetailCoverHeight(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: coverHeight,
              child: EventGroupDetailCover(group: _group),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: coverHeight - eventGroupDetailCoverOverlap,
                ),
                EventGroupDetailPinnedInfoSection(
                  group: _group,
                  aboutMaxLines: 2,
                  aboutExpanded: _aboutExpanded,
                  onAboutExpandedChanged: (expanded) {
                    setState(() => _aboutExpanded = expanded);
                  },
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: _linkedCards.isEmpty
                ? _buildEmptyCardsState(context)
                : _buildLinkedCardsCarousel(context),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCardsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: CustomButton(
          label: AppL10n.kartEkle(context.l10n),
          icon: Icons.person_add_alt_1_rounded,
          onPressed: _onAddCardPressed,
          fullWidth: false,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinkedCardsCarousel(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventGroupDetailLinkedCardsHeader(
          linkedCardCount: _linkedCards.length,
        ),
        const SizedBox(height: 4),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth =
                  (constraints.maxWidth - 40).clamp(240.0, 420.0);
              if ((_cardWidth - cardWidth).abs() > 0.5) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() => _cardWidth = cardWidth);
                });
              }
              return Column(
                children: [
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (_isProgrammaticScroll) return false;
                        if (notification is ScrollUpdateNotification) {
                          _syncFocusedIndexFromScroll();
                        } else if (notification is ScrollEndNotification) {
                          _syncFocusedIndexFromScroll();
                          _scheduleCenterFocusedCard();
                        }
                        return false;
                      },
                      child: SingleChildScrollView(
                        controller: _cardsScrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: _cardsHorizontalPadding,
                        ),
                        physics: const BouncingScrollPhysics(),
                        child: SavedCardsHorizontalStackView(
                          displayCards: _linkedCards,
                          focusedIndex: _focusedCardIndex,
                          cardWidth: _cardWidth,
                          onFocusedIndexChanged: _setFocusedCardIndex,
                          onOpenCard: (card, {heroTag}) => _openCardDetail(
                            card,
                            heroTag: heroTag,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SavedCardsFocusArrowTrack(
                    axis: Axis.horizontal,
                    focusedIndex: _focusedCardIndex,
                    cardCount: _linkedCards.length,
                    onFocusedIndexChanged: _setFocusedCardIndex,
                  ),
                  const SizedBox(height: 4),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return CardenceScaffold(
      appBar: CardenceAppBar(
        title: _group.name,
        actions: [
          if (widget.getNetworkGraph != null &&
              widget.getNetworkGraphPath != null)
            CardenceAppBar.iconAction(
              icon: Icons.hub_outlined,
              tooltip: AppL10n.viewEventNetwork(context.l10n),
              onPressed: _openNetworkGraph,
            ),
          CardenceAppBar.iconAction(
            icon: Icons.delete_outline_rounded,
            tooltip: AppL10n.buGrubuSil(context.l10n),
            onPressed: _confirmDeleteGroup,
          ),
        ],
      ),
      body: _loading
          ? const EventGroupDetailLoadingShimmer()
          : _buildBody(context, colorScheme, textTheme),
    );
  }
}
