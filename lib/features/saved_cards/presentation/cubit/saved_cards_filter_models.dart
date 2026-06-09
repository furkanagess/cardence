import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SavedCardsDateFilter { all, last7, last30, custom }

enum SavedCardsNameSort { asc, desc }

class SavedCardsFilterSelection extends Equatable {
  const SavedCardsFilterSelection({
    required this.eventFilter,
    required this.dateFilter,
    required this.nameSort,
    this.customDateRange,
  });

  static const String allEventsValue = 'Tüm etkinlikler';
  static const String ungroupedValue = '__ungrouped__';

  final String eventFilter;
  final SavedCardsDateFilter dateFilter;
  final SavedCardsNameSort nameSort;
  final DateTimeRange? customDateRange;

  int activeCount() {
    var count = 0;
    if (eventFilter != allEventsValue) count++;
    if (dateFilter != SavedCardsDateFilter.all) count++;
    return count;
  }

  bool get hasActiveFilters => activeCount() > 0;

  SavedCardsFilterSelection cleared() {
    return const SavedCardsFilterSelection(
      eventFilter: allEventsValue,
      dateFilter: SavedCardsDateFilter.all,
      nameSort: SavedCardsNameSort.asc,
    );
  }

  SavedCardsFilterSelection copyWith({
    String? eventFilter,
    SavedCardsDateFilter? dateFilter,
    SavedCardsNameSort? nameSort,
    DateTimeRange? customDateRange,
    bool clearCustomDateRange = false,
  }) {
    return SavedCardsFilterSelection(
      eventFilter: eventFilter ?? this.eventFilter,
      dateFilter: dateFilter ?? this.dateFilter,
      nameSort: nameSort ?? this.nameSort,
      customDateRange: clearCustomDateRange
          ? null
          : (customDateRange ?? this.customDateRange),
    );
  }

  @override
  List<Object?> get props => [
        eventFilter,
        dateFilter,
        nameSort,
        customDateRange,
      ];
}
