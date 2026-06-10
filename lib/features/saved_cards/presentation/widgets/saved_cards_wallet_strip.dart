import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/shimmer.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/saved_cards_wallet_limits.dart';
import 'wallet_quota_detail_sheet.dart';

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
    final atLimit = !quota.canAddMore;
    final barColor = atLimit
        ? colorScheme.error
        : quota.isNearLimit
            ? AppColors.secondary
            : AppColors.primary;

    final content = Material(
      color: inAppBar ? Colors.transparent : colorScheme.surfaceContainerLowest,
      borderRadius: inAppBar
          ? BorderRadius.zero
          : BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => WalletQuotaDetailSheet.show(
          context,
          quota: quota,
          isDemoMode: isDemoMode,
          onUpgradeTap: onUpgradeTap,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: inAppBar ? 10 : 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    isDemoMode ? '0' : '${quota.usedCount}',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color:
                          atLimit ? colorScheme.error : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    ' / ${quota.maxCards} kart',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (inAppBar) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: quota.usageFraction,
                  minHeight: 5,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: barColor,
                ),
              ),
              if (atLimit && !quota.isPremium) ...[
                const SizedBox(height: 6),
                Text(
                  'Limit doldu · Premium ile ${SavedCardsWalletLimits.premiumMaxCards} karta kadar',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (inAppBar) {
      return content;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: content,
    );
  }
}

/// Cüzdan kotası yüklenirken strip ile aynı boyutta iskelet.
class SavedCardsWalletStripShimmer extends StatelessWidget {
  const SavedCardsWalletStripShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 16),
      child: Shimmer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ShimmerPlaceholder(
                  width: 120,
                  height: 22,
                  borderRadius: 8,
                ),
                const SizedBox(height: 8),
                const ShimmerPlaceholder(
                  height: 5,
                  borderRadius: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
