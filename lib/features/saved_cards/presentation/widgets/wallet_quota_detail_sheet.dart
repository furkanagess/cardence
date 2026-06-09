import 'package:flutter/material.dart';

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${quota.usedCount}',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: atLimit ? colorScheme.error : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Text(
                    '/ ${quota.maxCards} kart',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: quota.usageFraction,
                minHeight: 8,
              ),
            ),
            if (isDemoMode) ...[
              const SizedBox(height: 14),
              Text(
                'Şu an örnek kartlar gösteriliyor. İlk kartınızı eklediğinizde gerçek cüzdanınız başlar; kota yalnızca sizin kaydettiğiniz kartları sayar.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ] else if (atLimit && !quota.isPremium) ...[
              const SizedBox(height: 14),
              Text(
                'Ücretsiz planda en fazla ${SavedCardsWalletLimits.freeMaxCards} kart saklayabilirsiniz. Premium ile ${SavedCardsWalletLimits.premiumMaxCards} karta kadar çıkabilirsiniz.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            if (!quota.isPremium && onUpgradeTap != null) ...[
              const SizedBox(height: 20),
              CustomButton(
                label: atLimit ? 'Paket al, sınırı artır' : 'Premium pakete geç',
                icon: Icons.workspace_premium_outlined,
                onPressed: () {
                  Navigator.of(context).pop();
                  onUpgradeTap!();
                },
                style: FilledButton.styleFrom(
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
