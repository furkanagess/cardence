import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/saved_cards_wallet_limits.dart';

class WalletQuotaDetailSheet extends StatelessWidget {
  const WalletQuotaDetailSheet({
    super.key,
    required this.quota,
    required this.isDemoMode,
    this.onUpgradeTap,
  });

  final SavedCardsWalletQuota quota;
  final bool isDemoMode;
  final VoidCallback? onUpgradeTap;

  static Future<void> show(
    BuildContext context, {
    required SavedCardsWalletQuota quota,
    required bool isDemoMode,
    VoidCallback? onUpgradeTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => WalletQuotaDetailSheet(
        quota: quota,
        isDemoMode: isDemoMode,
        onUpgradeTap: onUpgradeTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final atLimit = !quota.canAddMore;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Cüzdan kotası',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              quota.isPremium
                  ? 'Premium ile sınırsız kart saklayabilirsiniz.'
                  : 'Ücretsiz planda ${SavedCardsWalletLimits.freeMaxCards} karta kadar kayıt yapılır.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.outlineVariant.withValues(alpha: 0.7),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isDemoMode ? '0' : '${quota.usedCount}',
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color: atLimit && !quota.isPremium
                                ? AppColors.error
                                : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4, left: 4),
                          child: Text(
                            '/ ${quota.walletCapacityLabel} kart',
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!quota.hasUnlimitedWallet) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: quota.usageFraction,
                          minHeight: 8,
                          backgroundColor:
                              AppColors.surfaceVariant.withValues(alpha: 0.8),
                          color: atLimit
                              ? AppColors.error
                              : AppColors.primary,
                        ),
                      ),
                    ],
                    if (!quota.hasUnlimitedWallet && !isDemoMode) ...[
                      const SizedBox(height: 10),
                      Text(
                        quota.remainingSlotsLabel,
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isDemoMode) ...[
              const SizedBox(height: 14),
              Text(
                'Şu an örnek kartlar gösteriliyor. İlk kartınızı eklediğinizde gerçek cüzdanınız başlar.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ] else if (atLimit && !quota.isPremium) ...[
              const SizedBox(height: 14),
              Text(
                'Limit doldu. Premium ile sınırsız kart kaydedebilir, elle ve fotoğrafla eklemeye devam edebilirsiniz.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            if (!quota.isPremium && onUpgradeTap != null) ...[
              const SizedBox(height: 20),
              CustomButton(
                label: 'Sınırsız ol',
                icon: Icons.auto_awesome_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  onUpgradeTap!();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
