import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/shimmer.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import 'wallet_quota_detail_sheet.dart';
import 'wallet_quota_shared.dart';

/// Kompakt cüzdan kotası şeridi; dokununca detay sayfası açılır.
class SavedCardsWalletStrip extends StatelessWidget {
  const SavedCardsWalletStrip({
    super.key,
    required this.quota,
    required this.isDemoMode,
    this.inAppBar = false,
    this.onUpgradeTap,
  });

  final SavedCardsWalletQuota quota;
  final bool isDemoMode;
  final bool inAppBar;
  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final atLimit = !quota.canAddMore && !quota.isPremium;

    final content = Material(
      color: inAppBar
          ? Colors.transparent
          : colorScheme.surfaceContainerLowest.withValues(alpha: 0.65),
      borderRadius: inAppBar ? null : BorderRadius.circular(16),
      child: InkWell(
        onTap: () => WalletQuotaDetailSheet.show(
          context,
          quota: quota,
          isDemoMode: isDemoMode,
          onUpgradeTap: onUpgradeTap,
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            inAppBar ? 10 : 12,
            12,
            inAppBar ? 10 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _stripPrimaryLabel(quota, isDemoMode),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        color: atLimit
                            ? AppColors.error
                            : quota.isPremium
                                ? AppColors.success
                                : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (!quota.hasUnlimitedWallet && !isDemoMode)
                    Text(
                      '${quota.usedCount}/${quota.maxCards}',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                ],
              ),
              if (!quota.hasUnlimitedWallet) ...[
                const SizedBox(height: 10),
                WalletQuotaProgressBar(quota: quota),
              ],
            ],
          ),
        ),
      ),
    );

    if (inAppBar) return content;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: content,
    );
  }

  static String _stripPrimaryLabel(
    SavedCardsWalletQuota quota,
    bool isDemoMode,
  ) {
    if (isDemoMode) {
      return '${quota.maxCards} kart hakkınız var';
    }
    if (quota.isPremium) {
      return 'Sınırsız kart saklama';
    }
    if (!quota.canAddMore) {
      return 'Kart kotası doldu';
    }
    return walletQuotaRemainingLabel(quota);
  }
}

/// Cüzdan kotası yüklenirken strip ile aynı boyutta iskelet.
class SavedCardsWalletStripShimmer extends StatelessWidget {
  const SavedCardsWalletStripShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Shimmer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ShimmerPlaceholder(
                        width: double.infinity,
                        height: 18,
                        borderRadius: 6,
                      ),
                    ),
                    SizedBox(width: 8),
                    ShimmerPlaceholder(width: 36, height: 16, borderRadius: 6),
                  ],
                ),
                SizedBox(height: 10),
                ShimmerPlaceholder(height: 6, borderRadius: 3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
