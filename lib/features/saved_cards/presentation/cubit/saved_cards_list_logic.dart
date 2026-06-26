import '../../../../core/l10n/app_l10n.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../event_groups/domain/entities/event_group.dart';
import '../../domain/entities/saved_card.dart';
import 'saved_cards_filter_models.dart';

/// Kayıtlı kart listesi filtre ve sıralama yardımcıları.
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
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return cards;

    return cards.where((card) {
      final name = card.displayName?.toLowerCase() ?? '';
      final company = card.company?.toLowerCase() ?? '';
      final email = card.email?.toLowerCase() ?? '';
      return name.contains(clean) ||
          company.contains(clean) ||
          email.contains(clean);
    }).toList();
  }

  static List<SavedCard> applyFiltersAndSort({
    required List<SavedCard> cards,
    required SavedCardsFilterSelection filter,
  }) {
    final filtered = cards.where((card) {
      if (filter.eventFilter != SavedCardsFilterSelection.allEventsValue) {
        if (filter.eventFilter == SavedCardsFilterSelection.ungroupedValue) {
          if (card.linkedEventGroupIds.isNotEmpty) return false;
        } else {
          if (!card.linkedEventGroupIds.contains(filter.eventFilter)) {
            return false;
          }
        }
      }

      if (filter.dateFilter != SavedCardsDateFilter.all) {
        final savedAtMs = card.savedAt;
        if (savedAtMs == null) return false;
        final date = DateTime.fromMillisecondsSinceEpoch(savedAtMs);

        final now = DateTime.now();
        switch (filter.dateFilter) {
          case SavedCardsDateFilter.all:
            break;
          case SavedCardsDateFilter.last7:
            final threshold = now.subtract(const Duration(days: 7));
            if (date.isBefore(threshold)) return false;
            break;
          case SavedCardsDateFilter.last30:
            final threshold = now.subtract(const Duration(days: 30));
            if (date.isBefore(threshold)) return false;
            break;
          case SavedCardsDateFilter.custom:
            final range = filter.customDateRange;
            if (range == null) return false;
            final startOfDay =
                DateTime(range.start.year, range.start.month, range.start.day);
            final endOfDay = DateTime(
              range.end.year,
              range.end.month,
              range.end.day,
              23,
              59,
              59,
              999,
            );
            if (date.isBefore(startOfDay) || date.isAfter(endOfDay)) {
              return false;
            }
            break;
        }
      }

      return true;
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
    required AppLocalizations l10n,
    required List<SavedCard> sourceCards,
    required List<EventGroup> eventGroups,
  }) {
    final options = <({String value, String label})>[
      (
        value: SavedCardsFilterSelection.allEventsValue,
        label: AppL10n.tmEtkinlikler(l10n)
      ),
    ];
    if (sourceCards.any((c) => c.linkedEventGroupIds.isEmpty)) {
      options.add((
        value: SavedCardsFilterSelection.ungroupedValue,
        label: AppL10n.grupsuz(l10n),
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
}
