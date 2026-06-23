import '../../../event_groups/domain/entities/event_group.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_filter_models.dart';

/// Kayıtlı kart listesi filtre, sıralama ve sürükle-bırak yardımcıları.
class SavedCardsListLogic {
  SavedCardsListLogic._();

  static List<SavedCard> applyFiltersSortAndSearch({
    required List<SavedCard> cards,
    required SavedCardsFilterSelection filter,
    required String searchQuery,
  }) {
    final filtered = applyFiltersAndSort(cards: cards, filter: filter);
    return applySearch(cards: filtered, query: searchQuery);
  }

  static List<SavedCard> applySearch({
    required List<SavedCard> cards,
    required String query,
  }) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return cards;

    return cards.where((card) {
      return _searchableText(card).contains(normalized);
    }).toList();
  }

  static String _searchableText(SavedCard card) {
    return [
      card.displayName,
      card.company,
      card.title,
      card.email,
      card.phone,
      card.cardId,
      card.note,
    ].whereType<String>().join(' ').toLowerCase();
  }

  static List<SavedCard> applyFiltersAndSort({
    required List<SavedCard> cards,
    required SavedCardsFilterSelection filter,
  }) {
    var filtered = cards.where((card) {
      if (filter.eventFilter != SavedCardsFilterSelection.allEventsValue) {
        if (filter.eventFilter == SavedCardsFilterSelection.ungroupedValue) {
          if (card.linkedEventGroupIds.isNotEmpty) return false;
        } else if (!card.linkedEventGroupIds.contains(filter.eventFilter)) {
          return false;
        }
      }

      if (filter.dateFilter == SavedCardsDateFilter.all) return true;
      final savedAt = card.savedAt;
      if (savedAt == null) return false;
      final date = DateTime.fromMillisecondsSinceEpoch(savedAt);
      final now = DateTime.now();

      switch (filter.dateFilter) {
        case SavedCardsDateFilter.last7:
          return date.isAfter(now.subtract(const Duration(days: 7)));
        case SavedCardsDateFilter.last30:
          return date.isAfter(now.subtract(const Duration(days: 30)));
        case SavedCardsDateFilter.custom:
          final range = filter.customDateRange;
          if (range == null) return true;
          final start = DateTime(
            range.start.year,
            range.start.month,
            range.start.day,
          );
          final end = DateTime(
            range.end.year,
            range.end.month,
            range.end.day,
            23,
            59,
            59,
          );
          return !date.isBefore(start) && !date.isAfter(end);
        case SavedCardsDateFilter.all:
          return true;
      }
    }).toList();

    filtered.sort((a, b) {
      if (a.isOwnerPremium != b.isOwnerPremium) {
        return a.isOwnerPremium ? -1 : 1;
      }
      final aName = _sortKey(a);
      final bName = _sortKey(b);
      return filter.nameSort == SavedCardsNameSort.asc
          ? aName.compareTo(bName)
          : bName.compareTo(aName);
    });

    return filtered;
  }

  static String _sortKey(SavedCard card) {
    final name = card.displayName?.trim();
    if (name != null && name.isNotEmpty) return name.toLowerCase();
    return card.cardId.toLowerCase();
  }

  static List<({String value, String label})> eventFilterOptions({
    required List<SavedCard> sourceCards,
    required List<EventGroup> eventGroups,
  }) {
    final options = <({String value, String label})>[
      (value: SavedCardsFilterSelection.allEventsValue, label: 'Tüm etkinlikler'),
    ];
    if (sourceCards.any((c) => c.linkedEventGroupIds.isEmpty)) {
      options.add((
        value: SavedCardsFilterSelection.ungroupedValue,
        label: 'Grupsuz',
      ));
    }
    for (final group in eventGroups) {
      final hasCard =
          sourceCards.any((c) => c.linkedEventGroupIds.contains(group.id));
      if (hasCard) {
        options.add((value: group.id, label: group.name));
      }
    }
    return options;
  }

  static List<SavedCard> reorderCards({
    required List<SavedCard> targetList,
    required List<SavedCard> displayCards,
    required int fromIndex,
    required int toIndex,
    required bool filtersActive,
  }) {
    if (fromIndex == toIndex) return List<SavedCard>.from(targetList);

    final next = List<SavedCard>.from(targetList);
    if (!filtersActive) {
      final moved = next.removeAt(fromIndex);
      next.insert(toIndex, moved);
      return next;
    }

    final movedCard = displayCards[fromIndex];
    final targetCard = displayCards[toIndex];
    final fromRawIndex = next.indexWhere((e) => e.cardId == movedCard.cardId);
    final toRawIndex = next.indexWhere((e) => e.cardId == targetCard.cardId);
    if (fromRawIndex != -1 && toRawIndex != -1) {
      final moved = next.removeAt(fromRawIndex);
      next.insert(toRawIndex, moved);
    }
    return next;
  }

  static int visualSlotFor({
    required int index,
    required int? draggingIndex,
    required int? hoverTargetIndex,
  }) {
    final from = draggingIndex;
    if (from == null) return index;

    final to = hoverTargetIndex ?? from;
    if (index == from) return from;

    var slot = index;
    if (from < to) {
      if (index > from && index <= to) slot = index - 1;
    } else if (from > to) {
      if (index >= to && index < from) slot = index + 1;
    }
    return slot;
  }
}
