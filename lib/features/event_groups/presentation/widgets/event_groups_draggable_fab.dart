import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/molecules/draggable_fab.dart';

/// Etkinlik grupları ekranında sürüklenebilir ekleme FAB'ı.
class EventGroupsDraggableFab extends StatelessWidget {
  const EventGroupsDraggableFab({
    super.key,
    required this.canAddGroup,
    required this.onPressed,
    this.bottomClearance = 72,
    this.margin = 16,
  });

  final bool canAddGroup;
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
      builder: (effectiveOnPressed) => canAddGroup
          ? FloatingActionButton(
              heroTag: 'event_groups_add_fab',
              onPressed: effectiveOnPressed,
              tooltip: context.l10n.etkinlikGrubuEkle,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 4,
              child: const Icon(Icons.event_available_rounded),
            )
          : FloatingActionButton(
              heroTag: 'event_groups_upgrade_fab',
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
