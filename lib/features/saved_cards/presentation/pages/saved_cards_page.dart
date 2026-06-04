import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../event_groups/domain/entities/event_group.dart';
import '../../../event_groups/domain/usecases/get_event_groups.dart';
import '../../../event_groups/domain/usecases/save_event_groups.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../../domain/usecases/get_saved_cards.dart';
import '../../domain/usecases/get_saved_cards_wallet_quota.dart';
import '../../domain/usecases/save_saved_card.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';
import '../saved_cards_catalog.dart';
import '../widgets/add_saved_card_sheet.dart';
import '../widgets/saved_card_list_tile.dart';
import '../widgets/saved_cards_screen_toolbar.dart';
import '../widgets/saved_cards_wallet_strip.dart';
import '../widgets/wallet_upgrade_sheet.dart';
import 'add_card_by_id_page.dart';
import 'saved_card_detail_page.dart';
import 'scan_card_qr_page.dart';

/// Kaydettiği kişilerin kartları listesi.
class SavedCardsPage extends StatefulWidget {
  const SavedCardsPage({
    super.key,
    required this.getSavedCards,
    required this.saveSavedCard,
    required this.getEventGroups,
    required this.saveEventGroups,
    required this.showFlippableView,
    required this.filterTrigger,
    this.addCardTrigger = 0,
    required this.onViewModeChanged,
    required this.getSavedCardsWalletQuota,
    required this.addSavedCard,
    required this.upgradeWalletPlan,
  });

  final GetSavedCards getSavedCards;
  final SaveSavedCard saveSavedCard;
  final GetEventGroups getEventGroups;
  final SaveEventGroups saveEventGroups;
  final bool showFlippableView;
  final int filterTrigger;
  final int addCardTrigger;
  final ValueChanged<bool> onViewModeChanged;
  final GetSavedCardsWalletQuota getSavedCardsWalletQuota;
  final AddSavedCard addSavedCard;
  final UpgradeWalletPlan upgradeWalletPlan;

  @override
  State<SavedCardsPage> createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  static const Duration _dragAnimDuration = Duration(milliseconds: 320);
  static const Curve _dragAnimCurve = Curves.easeOutCubic;
  static const String _allEventsFilter = 'Tüm etkinlikler';
  static const String _ungroupedFilter = '__ungrouped__';

  List<SavedCard> _cards = [];
  List<EventGroup> _eventGroups = [];
  SavedCardsWalletQuota? _quota;
  late List<SavedCard> _dummyCardsOrder;
  int? _draggingCardIndex;
  int? _hoverTargetIndex;
  String _selectedEventFilter = _allEventsFilter;
  _NameSort _nameSort = _NameSort.none;
  _DateFilter _dateFilter = _DateFilter.all;
  DateTimeRange? _customDateRange;
  @override
  void initState() {
    super.initState();
    _dummyCardsOrder = List<SavedCard>.from(SavedCardsCatalog.demoCards);
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadCards(),
      _loadEventGroups(),
      _loadQuota(),
    ]);
  }

  Future<void> _loadQuota() async {
    final quota = await widget.getSavedCardsWalletQuota();
    if (!mounted) return;
    setState(() => _quota = quota);
  }

  Future<void> _loadEventGroups() async {
    final groups = await widget.getEventGroups();
    if (!mounted) return;
    setState(() => _eventGroups = groups);
  }

  Future<void> _loadCards() async {
    final list = await widget.getSavedCards();
    if (!mounted) return;
    setState(() {
      _cards = list;
    });
  }

  @override
  void didUpdateWidget(covariant SavedCardsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterTrigger != widget.filterTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final sourceCards = SavedCardsCatalog.isUsingDemoCards(_cards)
            ? _dummyCardsOrder
            : _cards;
        _openFilters(context, sourceCards);
      });
    }
    if (oldWidget.addCardTrigger != widget.addCardTrigger) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _onAddCardTap();
      });
    }
  }

  bool get _hasActiveFilters =>
      _selectedEventFilter != _allEventsFilter ||
      _dateFilter != _DateFilter.all ||
      _nameSort != _NameSort.none;

  int get _activeFilterCount {
    var n = 0;
    if (_selectedEventFilter != _allEventsFilter) n++;
    if (_dateFilter != _DateFilter.all) n++;
    if (_nameSort != _NameSort.none) n++;
    return n;
  }

  Future<void> _onAddCardTap() async {
    final quota = _quota ?? await widget.getSavedCardsWalletQuota();
    if (!mounted) return;

    if (!quota.canAddMore) {
      await _openUpgradeSheet();
      return;
    }

    final method = await AddSavedCardSheet.show(
      context,
      quota: quota,
      canAdd: quota.canAddMore,
    );
    if (!mounted || method == null) return;

    switch (method) {
      case AddSavedCardMethod.qrScan:
        final result = await Navigator.of(context).push<AddSavedCardResult>(
          MaterialPageRoute(
            builder: (_) => ScanCardQrPage(addSavedCard: widget.addSavedCard),
          ),
        );
        if (!mounted) return;
        await _handleAddResult(result);
      case AddSavedCardMethod.cardId:
        final result = await Navigator.of(context).push<AddSavedCardResult>(
          MaterialPageRoute(
            builder: (_) => AddCardByIdPage(addSavedCard: widget.addSavedCard),
          ),
        );
        if (!mounted) return;
        await _handleAddResult(result);
    }
  }

  Future<void> _handleAddResult(AddSavedCardResult? result) async {
    if (result == null) return;
    switch (result) {
      case AddSavedCardSuccess():
        await _refreshAll();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kart cüzdanınıza eklendi'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case AddSavedCardDuplicate():
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bu kart zaten kayıtlı'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case AddSavedCardLimitReached():
        await _openUpgradeSheet();
      case AddSavedCardInvalidPayload(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _openUpgradeSheet() async {
    final upgraded = await WalletUpgradeSheet.show(
      context,
      upgradeWalletPlan: widget.upgradeWalletPlan,
    );
    if (!mounted) return;
    await _loadQuota();
    if (upgraded == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium cüzdan etkinleştirildi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final useDummyCards = SavedCardsCatalog.isUsingDemoCards(_cards);
    final sourceCards = useDummyCards ? _dummyCardsOrder : _cards;
    final displayCards = _applyFiltersAndSort(sourceCards);
    const horizontalPadding = 20.0;
    const topPadding = 4.0;
    const cardVerticalStep = 64.0;
    const extraBottomPadding = 28.0;
    final quota = _quota;

    final cardsHeight = displayCards.isEmpty
        ? 0.0
        : ((displayCards.length - 1) * cardVerticalStep) + 260 + extraBottomPadding;

    final canAddMore = quota?.canAddMore ?? true;
    final isDemoMode = SavedCardsCatalog.isUsingDemoCards(_cards);

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
                        onUpgradeTap: _openUpgradeSheet,
                      )
                    : const Padding(
                        padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
                        child: SizedBox(
                          height: 72,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      ),
              ),
              SavedCardsScreenToolbar(
                showFlippableView: widget.showFlippableView,
                hasActiveFilters: _hasActiveFilters,
                activeFilterCount: _activeFilterCount,
                onViewModeChanged: widget.onViewModeChanged,
                onOpenFilters: () => _openFilters(context, sourceCards),
                onClearFilters: () {
                  setState(() {
                    _selectedEventFilter = _allEventsFilter;
                    _dateFilter = _DateFilter.all;
                    _nameSort = _NameSort.none;
                    _customDateRange = null;
                  });
                },
              ),
              Expanded(
                child: displayCards.isEmpty
                    ? _EmptyResultsView(
                        hasFilters: _hasActiveFilters,
                        onClearFilters: () {
                          setState(() {
                            _selectedEventFilter = _allEventsFilter;
                            _dateFilter = _DateFilter.all;
                            _nameSort = _NameSort.none;
                            _customDateRange = null;
                          });
                        },
                      )
                    : widget.showFlippableView
                ? SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      horizontalPadding,
                      topPadding,
                      horizontalPadding,
                      88,
                    ),
                    child: SizedBox(
                      height: cardsHeight,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              for (final i
                                  in _stackRenderOrder(displayCards.length))
                                AnimatedPositioned(
                                  duration: _dragAnimDuration,
                                  curve: _dragAnimCurve,
                                  top: _cardTopFor(i, cardVerticalStep),
                                  left: 0,
                                  right: 0,
                                  child: DragTarget<int>(
                                    onWillAcceptWithDetails: (details) {
                                      final from = details.data;
                                      return from != i;
                                    },
                                    onMove: (_) => _setHoverTarget(i),
                                    onLeave: (_) {
                                      if (_hoverTargetIndex != i) return;
                                      _setHoverTarget(null);
                                    },
                                    onAcceptWithDetails: (details) {
                                      _reorderCards(
                                        fromIndex: details.data,
                                        toIndex: i,
                                        useDummyCards: useDummyCards,
                                        displayCards: displayCards,
                                      );
                                    },
                                    builder:
                                        (context, candidateData, rejectedData) {
                                      final isDragging =
                                          _draggingCardIndex == i;

                                      return LongPressDraggable<int>(
                                        data: i,
                                        dragAnchorStrategy:
                                            pointerDragAnchorStrategy,
                                        feedback: SizedBox(
                                          width: constraints.maxWidth,
                                          height: 1,
                                        ),
                                        childWhenDragging:
                                            _buildDragPlaceholder(
                                          colorScheme,
                                        ),
                                        onDragStarted: () {
                                          HapticFeedback.mediumImpact();
                                          setState(() {
                                            _draggingCardIndex = i;
                                            _hoverTargetIndex = null;
                                          });
                                        },
                                        onDragEnd: (_) => _endDrag(),
                                        onDraggableCanceled: (_, __) =>
                                            _endDrag(),
                                        child: _buildSavedFlippableCard(
                                          displayCards[i],
                                          heroTag:
                                              'saved-card-${displayCards[i].cardId}',
                                          wrapHero: !isDragging,
                                          onTap: () => _openCardDetail(
                                            displayCards[i],
                                            heroTag:
                                                'saved-card-${displayCards[i].cardId}',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (_draggingCardIndex != null &&
                                  _hoverTargetIndex != null &&
                                  _hoverTargetIndex != _draggingCardIndex &&
                                  _draggingCardIndex! >= 0 &&
                                  _draggingCardIndex! < displayCards.length)
                                AnimatedPositioned(
                                  duration: _dragAnimDuration,
                                  curve: _dragAnimCurve,
                                  top: _dropPreviewTop(cardVerticalStep),
                                  left: 0,
                                  right: 0,
                                  child: IgnorePointer(
                                    child: _buildDropSlotCardPreview(
                                      displayCards[_draggingCardIndex!],
                                      colorScheme,
                                    ),
                                  ),
                                ),
                              if (_draggingCardIndex != null)
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 8,
                                  child: IgnorePointer(
                                    child: _buildDragHintChip(colorScheme),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
                    itemCount: displayCards.length,
                    itemBuilder: (context, index) {
                      final card = displayCards[index];
                      return SavedCardListTile(
                        card: card,
                        onTap: () => _openCardDetail(card),
                      );
                    },
                  ),
              ),
            ],
          ),
          Positioned(
            right: 20,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: FloatingActionButton.extended(
                onPressed: _onAddCardTap,
                icon: Icon(
                  canAddMore
                      ? Icons.add_rounded
                      : Icons.workspace_premium_outlined,
                ),
                label: Text(canAddMore ? 'Ekle' : 'Paket'),
                backgroundColor: canAddMore
                    ? AppColors.primary
                    : colorScheme.secondaryContainer,
                foregroundColor: canAddMore
                    ? AppColors.textOnPrimary
                    : colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<SavedCard> _applyFiltersAndSort(List<SavedCard> cards) {
    var filtered = cards.where((card) {
      if (_selectedEventFilter != _allEventsFilter) {
        if (_selectedEventFilter == _ungroupedFilter) {
          if (card.linkedEventGroupIds.isNotEmpty) return false;
        } else if (!card.linkedEventGroupIds.contains(_selectedEventFilter)) {
          return false;
        }
      }

      if (_dateFilter == _DateFilter.all) return true;
      final savedAt = card.savedAt;
      if (savedAt == null) return false;
      final date = DateTime.fromMillisecondsSinceEpoch(savedAt);
      final now = DateTime.now();

      switch (_dateFilter) {
        case _DateFilter.last7:
          return date.isAfter(now.subtract(const Duration(days: 7)));
        case _DateFilter.last30:
          return date.isAfter(now.subtract(const Duration(days: 30)));
        case _DateFilter.custom:
          if (_customDateRange == null) return true;
          final start = DateTime(
            _customDateRange!.start.year,
            _customDateRange!.start.month,
            _customDateRange!.start.day,
          );
          final end = DateTime(
            _customDateRange!.end.year,
            _customDateRange!.end.month,
            _customDateRange!.end.day,
            23,
            59,
            59,
          );
          return !date.isBefore(start) && !date.isAfter(end);
        case _DateFilter.all:
          return true;
      }
    }).toList();

    if (_nameSort != _NameSort.none) {
      filtered.sort((a, b) {
        final aName = (a.displayName ?? '').toLowerCase();
        final bName = (b.displayName ?? '').toLowerCase();
        return _nameSort == _NameSort.asc
            ? aName.compareTo(bName)
            : bName.compareTo(aName);
      });
    }

    return filtered;
  }

  List<({String value, String label})> _eventFilterOptions(
    List<SavedCard> sourceCards,
  ) {
    final options = <({String value, String label})>[
      (value: _allEventsFilter, label: 'Tüm etkinlikler'),
    ];
    if (sourceCards.any((c) => c.linkedEventGroupIds.isEmpty)) {
      options.add((value: _ungroupedFilter, label: 'Grupsuz'));
    }
    for (final group in _eventGroups) {
      final hasCard = sourceCards
          .any((c) => c.linkedEventGroupIds.contains(group.id));
      if (hasCard) {
        options.add((value: group.id, label: group.name));
      }
    }
    return options;
  }

  Future<void> _openFilters(
      BuildContext context, List<SavedCard> sourceCards) async {
    final eventOptions = _eventFilterOptions(sourceCards);
    if (!eventOptions.any((o) => o.value == _selectedEventFilter)) {
      _selectedEventFilter = _allEventsFilter;
    }

    var tempEvent = _selectedEventFilter;
    var tempSort = _nameSort;
    var tempDateFilter = _dateFilter;
    var tempCustomRange = _customDateRange;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kartları filtrele',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Liste ve kart görünümüne aynı filtreler uygulanır.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Etkinlik grubu',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: eventOptions.any((o) => o.value == tempEvent)
                        ? tempEvent
                        : _allEventsFilter,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: eventOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => tempEvent = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Eklenme tarihi',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<_DateFilter>(
                    initialValue: tempDateFilter,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: _DateFilter.all,
                        child: Text('Tüm tarihler'),
                      ),
                      DropdownMenuItem(
                        value: _DateFilter.last7,
                        child: Text('Son 7 gün'),
                      ),
                      DropdownMenuItem(
                        value: _DateFilter.last30,
                        child: Text('Son 30 gün'),
                      ),
                      DropdownMenuItem(
                        value: _DateFilter.custom,
                        child: Text('Özel aralık seç'),
                      ),
                    ],
                    onChanged: (value) async {
                      if (value == null) return;
                      if (value == _DateFilter.custom) {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: tempCustomRange,
                        );
                        if (picked != null) {
                          setModalState(() {
                            tempDateFilter = _DateFilter.custom;
                            tempCustomRange = picked;
                          });
                        }
                        return;
                      }
                      setModalState(() => tempDateFilter = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sıralama',
                    style: textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<_NameSort>(
                    initialValue: tempSort,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: _NameSort.none,
                        child: Text('Varsayılan'),
                      ),
                      DropdownMenuItem(
                        value: _NameSort.asc,
                        child: Text('A-Z'),
                      ),
                      DropdownMenuItem(
                        value: _NameSort.desc,
                        child: Text('Z-A'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => tempSort = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempEvent = _allEventsFilter;
                              tempSort = _NameSort.none;
                              tempDateFilter = _DateFilter.all;
                              tempCustomRange = null;
                            });
                          },
                          child: const Text('Sıfırla'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _selectedEventFilter = tempEvent;
                              _nameSort = tempSort;
                              _dateFilter = tempDateFilter;
                              _customDateRange = tempCustomRange;
                              _draggingCardIndex = null;
                              _hoverTargetIndex = null;
                            });
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Uygula'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<int> _stackRenderOrder(int length) {
    return List<int>.generate(length, (index) => index);
  }

  void _setHoverTarget(int? index) {
    if (_hoverTargetIndex == index) return;
    if (index != null) {
      HapticFeedback.selectionClick();
    }
    setState(() => _hoverTargetIndex = index);
  }

  void _endDrag() {
    if (!mounted) return;
    setState(() {
      _draggingCardIndex = null;
      _hoverTargetIndex = null;
    });
  }

  /// Sürükleme sırasında kartların görsel slot konumu (yer açma animasyonu).
  int _visualSlotFor(int index) {
    final from = _draggingCardIndex;
    if (from == null) return index;

    final to = _hoverTargetIndex ?? from;
    if (index == from) return from;

    var slot = index;
    if (from < to) {
      if (index > from && index <= to) slot = index - 1;
    } else if (from > to) {
      if (index >= to && index < from) slot = index + 1;
    }
    return slot;
  }

  double _cardTopFor(int index, double verticalStep) {
    return _visualSlotFor(index) * verticalStep;
  }

  double _dropPreviewTop(double verticalStep) {
    final to = _hoverTargetIndex ?? 0;
    return to * verticalStep;
  }

  Widget _buildDragPlaceholder(ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: _dragAnimDuration,
      curve: _dragAnimCurve,
      height: 24,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.drag_handle_rounded,
            size: 20,
            color: colorScheme.primary.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }

  Widget _buildDropSlotCardPreview(SavedCard card, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(_hoverTargetIndex),
      tween: Tween(begin: 0.96, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: child,
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.2),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: _buildSavedFlippableCard(card),
      ),
    );
  }

  Widget _buildDragHintChip(ColorScheme colorScheme) {
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 240),
        opacity: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.inverseSurface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_vert_rounded,
                  size: 18,
                  color: colorScheme.onInverseSurface,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bırakmak için konumu seçin',
                  style: TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reorderCards({
    required int fromIndex,
    required int toIndex,
    required bool useDummyCards,
    required List<SavedCard> displayCards,
  }) {
    if (fromIndex == toIndex) {
      _endDrag();
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      final targetList = useDummyCards ? _dummyCardsOrder : _cards;
      if (_selectedEventFilter == _allEventsFilter &&
          _dateFilter == _DateFilter.all &&
          _nameSort == _NameSort.none) {
        final moved = targetList.removeAt(fromIndex);
        targetList.insert(toIndex, moved);
      } else {
        final movedCard = displayCards[fromIndex];
        final targetCard = displayCards[toIndex];
        final fromRawIndex =
            targetList.indexWhere((e) => e.cardId == movedCard.cardId);
        final toRawIndex =
            targetList.indexWhere((e) => e.cardId == targetCard.cardId);
        if (fromRawIndex != -1 && toRawIndex != -1) {
          final moved = targetList.removeAt(fromRawIndex);
          targetList.insert(toRawIndex, moved);
        }
      }
      _draggingCardIndex = null;
      _hoverTargetIndex = null;
    });
  }

  Future<void> _openCardDetail(SavedCard card, {String? heroTag}) async {
    if (_draggingCardIndex != null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SavedCardDetailPage(
          card: card,
          heroTag: heroTag,
          getEventGroups: widget.getEventGroups,
          getSavedCards: widget.getSavedCards,
          saveEventGroups: widget.saveEventGroups,
          saveSavedCard: widget.saveSavedCard,
          onSave: _persistCardUpdate,
        ),
      ),
    );
    if (!mounted) return;
    await _refreshAll();
  }

  Future<void> _persistCardUpdate(SavedCard updated) async {
    if (_cards.isEmpty) {
      setState(() {
        _dummyCardsOrder = _dummyCardsOrder
            .map((c) => c.cardId == updated.cardId ? updated : c)
            .toList();
      });
      return;
    }

    await widget.saveSavedCard(updated);
    if (!mounted) return;
    setState(() {
      _cards =
          _cards.map((c) => c.cardId == updated.cardId ? updated : c).toList();
    });
  }

  Widget _buildSavedFlippableCard(
    SavedCard card, {
    VoidCallback? onTap,
    String? heroTag,
    bool wrapHero = false,
  }) {
    final displayName = card.displayName?.trim().isEmpty ?? true
        ? 'Kart ${card.cardId.substring(0, 8)}...'
        : card.displayName!;
    final companyName = card.company?.trim();

    final frontEntries = <({String label, String value})>[
      if (card.title != null && card.title!.trim().isNotEmpty)
        (label: 'Ünvan', value: card.title!.trim()),
      if (card.email != null && card.email!.trim().isNotEmpty)
        (label: 'E-posta', value: card.email!.trim()),
      if (card.phone != null && card.phone!.trim().isNotEmpty)
        (label: 'Telefon', value: card.phone!.trim()),
    ];

    final backEntries = <({String label, String value})>[
      if (card.about != null && card.about!.trim().isNotEmpty)
        (label: 'Notlar', value: card.about!.trim()),
    ];

    final cardWidget = FlippablePersonCard(
      title: displayName,
      titleSecondary: companyName,
      frontEntries: frontEntries,
      backEntries: backEntries,
      emptyMessage: 'Kart bilgisi yok',
      backEmptyMessage: 'Bu kisi icin not bulunmuyor.',
      backEmptyActionLabel: 'Not ekle',
      onBackEmptyActionTap: () => _openAddNoteModal(card),
      onBackEditTap: (card.about != null && card.about!.trim().isNotEmpty)
          ? () => _openAddNoteModal(card)
          : null,
      onTap: onTap,
    );

    if (!wrapHero || heroTag == null) return cardWidget;

    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.transparent,
        child: cardWidget,
      ),
    );
  }

  Future<void> _openAddNoteModal(SavedCard card) async {
    var draftNote = card.about ?? '';
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Kisi notu',
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
                      decoration: const InputDecoration(
                        hintText: 'Bu kisi hakkinda not yazin',
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: () =>
                          Navigator.of(context).pop(draftNote.trim()),
                      child: const Text('Kaydet'),
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
        about: note.isEmpty ? null : note,
        clearAbout: note.isEmpty,
      ),
    );
  }
}

class _EmptyResultsView extends StatelessWidget {
  const _EmptyResultsView({
    required this.hasFilters,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off_rounded : Icons.credit_card_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'Filtreye uyan kart yok' : 'Henüz kayıtlı kart yok',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Farklı filtre deneyin veya filtreleri temizleyin.'
                  : 'QR okutarak veya kart ID girerek ilk kartınızı ekleyin.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (hasFilters)
              OutlinedButton(
                onPressed: onClearFilters,
                child: const Text('Filtreleri temizle'),
              )
            else
              Text(
                'Sağ alttaki Ekle ile QR okutun veya kart ID girin',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

enum _NameSort { none, asc, desc }

enum _DateFilter { all, last7, last30, custom }
