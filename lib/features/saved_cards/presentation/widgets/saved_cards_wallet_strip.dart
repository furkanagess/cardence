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
    final showUpgrade = !quota.isPremium && onUpgradeTap != null;
    final progressColor = atLimit
        ? AppColors.error
        : quota.isNearLimit
            ? AppColors.warning
            : AppColors.primary;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: inAppBar ? Colors.transparent : colorScheme.surface,
        borderRadius: inAppBar ? BorderRadius.zero : BorderRadius.circular(16),
        border: inAppBar
            ? null
            : Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.85),
              ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          inAppBar ? 10 : 14,
          16,
          inAppBar ? 10 : 14,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () => WalletQuotaDetailSheet.show(
                context,
                quota: quota,
                isDemoMode: isDemoMode,
                onUpgradeTap: onUpgradeTap,
              ),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _WalletIconBadge(isPremium: quota.isPremium),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cüzdan kotası',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _statusSubtitle(quota, isDemoMode),
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (quota.isPremium)
                          const _PremiumActiveChip()
                        else
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 22,
                            color: colorScheme.onSurfaceVariant,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isDemoMode ? '0' : '${quota.usedCount}',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1,
                            color: atLimit && !quota.isPremium
                                ? AppColors.error
                                : colorScheme.onSurface,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2, left: 4),
                          child: Text(
                            '/ ${quota.walletCapacityLabel}',
                            style: textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!quota.hasUnlimitedWallet && !isDemoMode)
                          Text(
                            '${quota.remaining} boş',
                            style: textTheme.labelMedium?.copyWith(
                              color: atLimit
                                  ? AppColors.error
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    if (!quota.hasUnlimitedWallet) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: quota.usageFraction,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.75),
                          color: progressColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (isDemoMode) ...[
              const SizedBox(height: 12),
              _InfoBanner(
                message:
                    'Örnek kartlar gösteriliyor. İlk kartınızı eklediğinizde gerçek cüzdanınız başlar.',
                tone: _WalletBannerTone.neutral,
              ),
            ] else if (atLimit && !quota.isPremium) ...[
              const SizedBox(height: 12),
              _InfoBanner(
                message:
                    '${SavedCardsWalletLimits.freeMaxCards} kart limitine ulaştınız. Premium ile sınırsız kaydedin.',
                tone: _WalletBannerTone.warning,
              ),
            ],
            if (showUpgrade) ...[
              const SizedBox(height: 12),
              _PremiumUpsellButton(onTap: onUpgradeTap!),
            ],
          ],
        ),
      ),
    );

    if (inAppBar) {
      return content;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: content,
    );
  }

  static String _statusSubtitle(SavedCardsWalletQuota quota, bool isDemoMode) {
    if (isDemoMode) return 'Henüz kayıtlı kart yok';
    if (quota.isPremium) return 'Sınırsız kart saklama aktif';
    if (!quota.canAddMore) return 'Limit doldu · yükseltme gerekli';
    if (quota.isNearLimit) return 'Kota dolmak üzere';
    return '${quota.remaining} kart daha ekleyebilirsiniz';
  }
}

class _WalletIconBadge extends StatelessWidget {
  const _WalletIconBadge({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isPremium
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isPremium ? Icons.workspace_premium_rounded : Icons.wallet_rounded,
        size: 22,
        color: colorScheme.primary,
      ),
    );
  }
}

class _PremiumActiveChip extends StatelessWidget {
  const _PremiumActiveChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.25),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            'Premium',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

enum _WalletBannerTone { neutral, warning }

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.message,
    required this.tone,
  });

  final String message;
  final _WalletBannerTone tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isWarning = tone == _WalletBannerTone.warning;
    final background = isWarning
        ? AppColors.warning.withValues(alpha: 0.1)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);
    final foreground = isWarning
        ? AppColors.warning
        : colorScheme.onSurfaceVariant;
    final icon = isWarning
        ? Icons.info_outline_rounded
        : Icons.lightbulb_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                    color: foreground,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumUpsellButton extends StatelessWidget {
  const _PremiumUpsellButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 20,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sınırsız ol',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sınırsız kart, elle ekleme ve daha fazlası',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Shimmer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.85),
            ),
          ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ShimmerPlaceholder(width: 40, height: 40, borderRadius: 12),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerPlaceholder(
                            width: 100,
                            height: 14,
                            borderRadius: 6,
                          ),
                          SizedBox(height: 6),
                          ShimmerPlaceholder(
                            width: 160,
                            height: 12,
                            borderRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ShimmerPlaceholder(width: 72, height: 28, borderRadius: 8),
                SizedBox(height: 10),
                ShimmerPlaceholder(height: 6, borderRadius: 6),
                SizedBox(height: 12),
                ShimmerPlaceholder(height: 56, borderRadius: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
