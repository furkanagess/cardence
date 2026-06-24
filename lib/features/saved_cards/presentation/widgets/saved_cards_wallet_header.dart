import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/saved_cards_wallet_limits.dart';

/// Kaydedilen kartlar ekranı üst kotası ve paket bilgisi.
class SavedCardsWalletHeader extends StatelessWidget {
  const SavedCardsWalletHeader({
    super.key,
    required this.quota,
    required this.isDemoMode,
    required this.onUpgradeTap,
  });

  final SavedCardsWalletQuota quota;
  final bool isDemoMode;
  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final atLimit = !quota.canAddMore;
    final progressColor = atLimit
        ? colorScheme.error
        : quota.isNearLimit
            ? AppColors.secondary
            : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '${quota.usedCount}',
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: atLimit ? colorScheme.error : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    ' / ${quota.walletCapacityLabel} kart',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: quota.usageFraction,
                  minHeight: 6,
                  backgroundColor:
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                  color: progressColor,
                ),
              ),
              if (isDemoMode) ...[
                const SizedBox(height: 10),
                Text(
                  context.l10n.rnekKartlarGsteriliyorlkKartnz,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ] else if (atLimit && !quota.isPremium) ...[
                const SizedBox(height: 10),
                Text(
                  'Ücretsiz planda en fazla ${SavedCardsWalletLimits.freeMaxCards} kart saklayabilirsiniz.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
              if (!quota.isPremium && onUpgradeTap != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: CustomButton.tonal(
                    label: atLimit ? 'Paket al, sınırı artır' : 'Premium pakete geç',
                    icon: Icons.workspace_premium_outlined,
                    onPressed: onUpgradeTap,
                    fullWidth: false,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
