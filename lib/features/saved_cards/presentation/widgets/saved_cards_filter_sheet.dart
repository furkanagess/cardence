import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/widgets/atoms/custom_button.dart';
import '../cubit/saved_cards_filter_models.dart';

class SavedCardsFilterSheet extends StatelessWidget {
  const SavedCardsFilterSheet({
    super.key,
    required this.initial,
    required this.eventOptions,
    required this.allEventsValue,
  });

  final SavedCardsFilterSelection initial;
  final List<({String value, String label})> eventOptions;
  final String allEventsValue;

  static Future<SavedCardsFilterSelection?> show(
    BuildContext context, {
    required SavedCardsFilterSelection initial,
    required List<({String value, String label})> eventOptions,
    required String allEventsValue,
  }) {
    return showModalBottomSheet<SavedCardsFilterSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SavedCardsFilterSheet(
        initial: initial,
        eventOptions: eventOptions,
        allEventsValue: allEventsValue,
      ),
    );
  }

  static String _formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    var tempEvent = initial.eventFilter;
    var tempSort = initial.nameSort;
    var tempDateFilter = initial.dateFilter;
    var tempCustomRange = initial.customDateRange;

    return StatefulBuilder(
      builder: (context, setModalState) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final textTheme = theme.textTheme;
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        SavedCardsFilterSelection currentSelection() {
          return SavedCardsFilterSelection(
            eventFilter: tempEvent,
            dateFilter: tempDateFilter,
            nameSort: tempSort,
            customDateRange: tempCustomRange,
          );
        }

        void resetAll() {
          setModalState(() {
            tempEvent = allEventsValue;
            tempSort = SavedCardsNameSort.asc;
            tempDateFilter = SavedCardsDateFilter.all;
            tempCustomRange = null;
          });
        }

        final hasChangesFromInitial = tempEvent != initial.eventFilter ||
            tempSort != initial.nameSort ||
            tempDateFilter != initial.dateFilter ||
            tempCustomRange != initial.customDateRange;

        final activeCount = currentSelection().activeCount();

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, bottomInset + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.filtreler,
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.listeVeKartGrnmneBirlikte,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: context.l10n.kapat,
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                if (activeCount > 0) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (tempEvent != allEventsValue)
                        _ActiveFilterChip(
                          label: eventOptions
                                  .where((o) => o.value == tempEvent)
                                  .map((o) => o.label)
                                  .firstOrNull ??
                              'Etkinlik',
                          onRemove: () =>
                              setModalState(() => tempEvent = allEventsValue),
                        ),
                      if (tempDateFilter != SavedCardsDateFilter.all)
                        _ActiveFilterChip(
                          label: _dateFilterLabel(
                            context.l10n,
                            tempDateFilter,
                            tempCustomRange,
                          ),
                          onRemove: () => setModalState(() {
                            tempDateFilter = SavedCardsDateFilter.all;
                            tempCustomRange = null;
                          }),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                _FilterSection(
                  icon: Icons.event_rounded,
                  title: context.l10n.etkinlikGrubu2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: eventOptions.map((option) {
                        final selected = tempEvent == option.value;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(option.label),
                            selected: selected,
                            showCheckmark: false,
                            onSelected: (_) => setModalState(
                              () => tempEvent = option.value,
                            ),
                            labelStyle: textTheme.labelLarge?.copyWith(
                              fontWeight:
                                  selected ? FontWeight.w600 : FontWeight.w500,
                              color: selected
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                            ),
                            selectedColor: colorScheme.primaryContainer
                                .withValues(alpha: 0.85),
                            backgroundColor: colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.35),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _FilterSection(
                  icon: Icons.calendar_month_rounded,
                  title: context.l10n.eklenmeTarihi,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _DateFilterChip(
                        label: context.l10n.tm,
                        selected: tempDateFilter == SavedCardsDateFilter.all,
                        onTap: () => setModalState(() {
                          tempDateFilter = SavedCardsDateFilter.all;
                          tempCustomRange = null;
                        }),
                      ),
                      _DateFilterChip(
                        label: context.l10n.son7Gn,
                        selected: tempDateFilter == SavedCardsDateFilter.last7,
                        onTap: () => setModalState(() {
                          tempDateFilter = SavedCardsDateFilter.last7;
                          tempCustomRange = null;
                        }),
                      ),
                      _DateFilterChip(
                        label: context.l10n.son30Gn,
                        selected: tempDateFilter == SavedCardsDateFilter.last30,
                        onTap: () => setModalState(() {
                          tempDateFilter = SavedCardsDateFilter.last30;
                          tempCustomRange = null;
                        }),
                      ),
                      _DateFilterChip(
                        label: tempDateFilter == SavedCardsDateFilter.custom &&
                                tempCustomRange != null
                            ? '${_formatShortDate(tempCustomRange!.start)} – ${_formatShortDate(tempCustomRange!.end)}'
                            : context.l10n.zelAralk,
                        selected: tempDateFilter == SavedCardsDateFilter.custom,
                        icon: Icons.date_range_rounded,
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            initialDateRange: tempCustomRange,
                          );
                          if (!context.mounted || picked == null) return;
                          setModalState(() {
                            tempDateFilter = SavedCardsDateFilter.custom;
                            tempCustomRange = picked;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _FilterSection(
                  icon: Icons.sort_rounded,
                  title: context.l10n.sralama,
                  child: SegmentedButton<SavedCardsNameSort>(
                    segments: [
                      ButtonSegment(
                        value: SavedCardsNameSort.asc,
                        label: Text(context.l10n.aZ),
                      ),
                      ButtonSegment(
                        value: SavedCardsNameSort.desc,
                        label: Text(context.l10n.zA),
                      ),
                    ],
                    selected: {tempSort},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      setModalState(() => tempSort = selection.first);
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton.tonal(
                        label: context.l10n.sfrla,
                        onPressed: activeCount > 0 ? resetAll : null,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        label: hasChangesFromInitial ? context.l10n.apply : context.l10n.close,
                        onPressed: () {
                          if (!hasChangesFromInitial) {
                            Navigator.of(context).pop();
                            return;
                          }
                          Navigator.of(context).pop(currentSelection());
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _dateFilterLabel(
    AppLocalizations l10n,
    SavedCardsDateFilter filter,
    DateTimeRange? range,
  ) {
    switch (filter) {
      case SavedCardsDateFilter.all:
        return l10n.tmTarihler;
      case SavedCardsDateFilter.last7:
        return l10n.son7Gn;
      case SavedCardsDateFilter.last30:
        return l10n.son30Gn;
      case SavedCardsDateFilter.custom:
        if (range == null) return l10n.zelAralk;
        return '${_formatShortDate(range.start)} – ${_formatShortDate(range.end)}';
    }
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  icon,
                  size: 16,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _DateFilterChip extends StatelessWidget {
  const _DateFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.85)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChip extends StatelessWidget {
  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InputChip(
      label: Text(label),
      deleteIcon: Icon(
        Icons.close_rounded,
        size: 16,
        color: colorScheme.onPrimaryContainer,
      ),
      onDeleted: onRemove,
      labelStyle: textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimaryContainer,
      ),
      backgroundColor: colorScheme.primaryContainer.withValues(alpha: 0.7),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
