import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Görünüm modu ve hızlı filtre erişimi.
class SavedCardsScreenToolbar extends StatelessWidget {
  const SavedCardsScreenToolbar({
    super.key,
    required this.showFlippableView,
    required this.hasActiveFilters,
    required this.activeFilterCount,
    required this.onViewModeChanged,
    required this.onOpenFilters,
  });

  final bool showFlippableView;
  final bool hasActiveFilters;
  final int activeFilterCount;
  final ValueChanged<bool> onViewModeChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Kart'),
                  icon: Icon(Icons.style_rounded, size: 18),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Liste'),
                  icon: Icon(Icons.view_list_rounded, size: 18),
                ),
              ],
              selected: {showFlippableView},
              onSelectionChanged: (set) => onViewModeChanged(set.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          IconButton(
            tooltip: hasActiveFilters
                ? 'Filtre ($activeFilterCount)'
                : 'Filtrele',
            onPressed: onOpenFilters,
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              label: Text('$activeFilterCount'),
              backgroundColor: AppColors.primary,
              textColor: AppColors.textOnPrimary,
              child: Icon(
                Icons.tune_rounded,
                color: hasActiveFilters
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            style: IconButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}
