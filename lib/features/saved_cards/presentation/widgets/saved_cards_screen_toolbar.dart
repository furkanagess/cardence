import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';

/// Görünüm modu, genişleyen arama ve filtre erişimi.
class SavedCardsScreenToolbar extends StatefulWidget {
  const SavedCardsScreenToolbar({
    super.key,
    required this.showFlippableView,
    required this.onViewModeChanged,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.hasActiveFilters,
    required this.hasActiveSearch,
    required this.activeFilterCount,
    required this.onOpenFilters,
  });

  final bool showFlippableView;
  final ValueChanged<bool> onViewModeChanged;
  final String searchQuery;
  final ValueChanged<String> onSearchQueryChanged;
  final bool hasActiveFilters;
  final bool hasActiveSearch;
  final int activeFilterCount;
  final VoidCallback onOpenFilters;

  @override
  State<SavedCardsScreenToolbar> createState() =>
      _SavedCardsScreenToolbarState();
}

class _SavedCardsScreenToolbarState extends State<SavedCardsScreenToolbar> {
  bool _searchExpanded = false;
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _searchFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant SavedCardsScreenToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _expandSearch() {
    setState(() => _searchExpanded = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _searchFocusNode.requestFocus();
    });
  }

  void _collapseSearch({bool clearQuery = false}) {
    _searchFocusNode.unfocus();
    if (clearQuery && _searchController.text.isNotEmpty) {
      _searchController.clear();
      widget.onSearchQueryChanged('');
    }
    setState(() => _searchExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Row(
          children: [
            Expanded(
              child: _searchExpanded
                  ? CustomTextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      hintText: 'İsim, şirket, e-posta…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 22),
                      suffixIcon: IconButton(
                        tooltip: 'Aramayı kapat',
                        onPressed: () => _collapseSearch(clearQuery: true),
                        icon: const Icon(Icons.close_rounded, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                      textInputAction: TextInputAction.search,
                      onChanged: widget.onSearchQueryChanged,
                      onSubmitted: widget.onSearchQueryChanged,
                    )
                  : SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          label: Text('Kart'),
                          icon: Icon(Icons.style_rounded, size: 18),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text('Liste'),
                          icon: Icon(Icons.view_list_rounded, size: 18),
                        ),
                      ],
                      selected: {widget.showFlippableView ? 0 : 1},
                      onSelectionChanged: (set) =>
                          widget.onViewModeChanged(set.first == 0),
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
            ),
            if (!_searchExpanded) ...[
              IconButton(
                tooltip: widget.hasActiveSearch ? 'Arama aktif' : 'Ara',
                onPressed: _expandSearch,
                icon: Badge(
                  isLabelVisible: widget.hasActiveSearch,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.search_rounded,
                    color: widget.hasActiveSearch
                        ? AppColors.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                style: IconButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
            IconButton(
              tooltip: widget.hasActiveFilters
                  ? 'Filtre (${widget.activeFilterCount})'
                  : 'Filtrele',
              onPressed: widget.onOpenFilters,
              icon: Badge(
                isLabelVisible: widget.hasActiveFilters,
                label: Text('${widget.activeFilterCount}'),
                backgroundColor: AppColors.primary,
                textColor: AppColors.textOnPrimary,
                child: Icon(
                  Icons.tune_rounded,
                  color: widget.hasActiveFilters
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
      ),
    );
  }
}
