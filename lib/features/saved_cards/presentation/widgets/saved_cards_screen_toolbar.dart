import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';

/// Arama ve filtre araç çubuğu.
class SavedCardsScreenToolbar extends StatefulWidget {
  const SavedCardsScreenToolbar({
    super.key,
    required this.searchQuery,
    required this.onSearchQueryChanged,
    required this.hasActiveFilters,
    required this.hasActiveSearch,
    required this.activeFilterCount,
    required this.onOpenFilters,
  });

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
  static const double _fieldHeight = 48;
  static const double _fieldRadius = 10;

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fieldFillColor =
        isDark ? AppColors.surfaceVariantDark : AppColors.surfaceLight;
    final fieldBorderColor = isDark ? AppColors.outlineDark : AppColors.outline;
    final iconColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
              height: _fieldHeight,
              child: CustomTextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: widget.onSearchQueryChanged,
                onSubmitted: widget.onSearchQueryChanged,
                decoration: CustomTextField.themedDecoration(
                  context,
                  hintText: context.l10n.search,
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  suffixIcon: widget.hasActiveSearch
                      ? IconButton(
                          tooltip: context.l10n.aramayKapat,
                          onPressed: () => widget.onSearchQueryChanged(''),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
                ).copyWith(
                  filled: true,
                  fillColor: fieldFillColor,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_fieldRadius),
                    borderSide: BorderSide(color: fieldBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_fieldRadius),
                    borderSide: BorderSide(
                      color: isDark
                          ? AppColors.primaryDarkTheme
                          : AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: fieldFillColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_fieldRadius),
              side: BorderSide(color: fieldBorderColor),
            ),
            child: InkWell(
              onTap: widget.onOpenFilters,
              borderRadius: BorderRadius.circular(_fieldRadius),
              child: SizedBox(
                width: _fieldHeight,
                height: _fieldHeight,
                child: Center(
                  child: Badge(
                    isLabelVisible: widget.hasActiveFilters,
                    label: Text('${widget.activeFilterCount}'),
                    backgroundColor: AppColors.primary,
                    textColor: AppColors.textOnPrimary,
                    child: Icon(
                      Icons.tune_rounded,
                      color: widget.hasActiveFilters
                          ? AppColors.primary
                          : iconColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
