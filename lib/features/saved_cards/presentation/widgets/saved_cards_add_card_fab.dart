import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/molecules/draggable_fab.dart';

/// Kaydedilen kartlar ekranında sürüklenebilir klasik [FloatingActionButton].
class SavedCardsDraggableFab extends StatelessWidget {
  const SavedCardsDraggableFab({
    super.key,
    required this.canAddMore,
    required this.onPressed,
    this.bottomClearance = 72,
    this.margin = 16,
  });

  final bool canAddMore;
  final VoidCallback onPressed;
  final double bottomClearance;
  final double margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableFab(
      onPressed: onPressed,
      bottomClearance: bottomClearance,
      margin: margin,
      builder: (effectiveOnPressed) => canAddMore
          ? FloatingActionButton(
              heroTag: 'saved_cards_add_fab',
              onPressed: effectiveOnPressed,
              tooltip: context.l10n.kartEkle,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 4,
              child: const Icon(Icons.add_card_rounded),
            )
          : FloatingActionButton(
              heroTag: 'saved_cards_upgrade_fab',
              onPressed: effectiveOnPressed,
              tooltip: context.l10n.kapasiteyiArtr,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.primary,
              elevation: 3,
              child: Icon(
                Icons.workspace_premium_outlined,
                color: colorScheme.primary,
              ),
            ),
    );
  }
}
