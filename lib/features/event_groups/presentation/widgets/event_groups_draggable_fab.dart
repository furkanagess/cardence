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
  });

  final bool canAddGroup;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: DraggableFab(
        positionStorageKey: 'event_groups_add_fab_v2',
        onPressed: onPressed,
        builder: (onTap) => canAddGroup
            ? FloatingActionButton.extended(
                heroTag: 'event_groups_add_fab',
                onPressed: onTap,
                tooltip: context.l10n.yeniEtkinlikGrubu,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 4,
                shape: const StadiumBorder(),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  context.l10n.yeniEtkinlikGrubu,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnPrimary,
                      ),
                ),
              )
            : FloatingActionButton.extended(
                heroTag: 'event_groups_upgrade_fab',
                onPressed: onTap,
                tooltip: context.l10n.kapasiteyiArtr,
                backgroundColor: colorScheme.surface,
                foregroundColor: colorScheme.primary,
                elevation: 3,
                shape: const StadiumBorder(),
                icon: Icon(
                  Icons.workspace_premium_outlined,
                  color: colorScheme.primary,
                ),
                label: Text(
                  context.l10n.kapasiteyiArtr,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                ),
              ),
      ),
    );
  }
}
