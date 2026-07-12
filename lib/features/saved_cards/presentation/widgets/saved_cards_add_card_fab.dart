import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/molecules/draggable_fab.dart';

/// Kaydedilen kartlar ekranında sürüklenebilir kart ekleme FAB'ı.
class SavedCardsAddCardFab extends StatelessWidget {
  const SavedCardsAddCardFab({
    super.key,
    required this.canAddMore,
    required this.onPressed,
  });

  final bool canAddMore;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Positioned.fill(
      child: DraggableFab(
        positionStorageKey: 'saved_cards_add_card_fab_v2',
        onPressed: onPressed,
        builder: (onTap) => canAddMore
            ? FloatingActionButton.extended(
                heroTag: 'saved_cards_add_fab',
                onPressed: onTap,
                tooltip: context.l10n.kartEkle,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 4,
                shape: const StadiumBorder(),
                icon: const Icon(Icons.add_rounded),
                label: Text(
                  context.l10n.yeniKartEkle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textOnPrimary,
                      ),
                ),
              )
            : FloatingActionButton.extended(
                heroTag: 'saved_cards_upgrade_fab',
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
