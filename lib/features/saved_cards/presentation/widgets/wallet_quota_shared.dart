import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';

Color walletQuotaProgressColor(
  SavedCardsWalletQuota quota,
  ColorScheme colorScheme,
) {
  if (quota.isPremium) return AppColors.success;
  if (!quota.canAddMore) return AppColors.error;
  if (quota.isNearLimit) return AppColors.warning;
  return colorScheme.primary;
}

class WalletQuotaPlanChip extends StatelessWidget {
  const WalletQuotaPlanChip({
    super.key,
    required this.isPremium,
    this.compact = false,
  });

  final bool isPremium;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = isPremium
        ? AppColors.success.withValues(alpha: 0.12)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.85);
    final foreground = isPremium ? AppColors.success : colorScheme.onSurfaceVariant;
    final label = isPremium ? 'Premium' : 'Ücretsiz';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPremium) ...[
            Icon(Icons.verified_rounded, size: compact ? 12 : 14, color: foreground),
            SizedBox(width: compact ? 3 : 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              color: foreground,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class WalletQuotaProgressBar extends StatelessWidget {
  const WalletQuotaProgressBar({
    super.key,
    required this.quota,
    this.height = 6,
  });

  final SavedCardsWalletQuota quota;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (quota.hasUnlimitedWallet) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: quota.usageFraction,
        minHeight: height,
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        color: walletQuotaProgressColor(quota, colorScheme),
      ),
    );
  }
}

enum WalletQuotaLimitTone { neutral, success, warning, error }

class WalletQuotaLimitRow extends StatelessWidget {
  const WalletQuotaLimitRow({
    super.key,
    required this.icon,
    required this.title,
    required this.valueLabel,
    this.subtitle,
    this.tone = WalletQuotaLimitTone.neutral,
  });

  final IconData icon;
  final String title;
  final String valueLabel;
  final String? subtitle;
  final WalletQuotaLimitTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(
          alpha: isDark ? 0.55 : 0.85,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.outlineDark.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          subtitle!,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ValueBadge(label: valueLabel, tone: tone),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueBadge extends StatelessWidget {
  const _ValueBadge({
    required this.label,
    required this.tone,
  });

  final String label;
  final WalletQuotaLimitTone tone;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final (background, foreground) = switch (tone) {
      WalletQuotaLimitTone.success => (
          AppColors.success.withValues(alpha: 0.12),
          AppColors.success,
        ),
      WalletQuotaLimitTone.warning => (
          AppColors.warning.withValues(alpha: 0.12),
          AppColors.warning,
        ),
      WalletQuotaLimitTone.error => (
          AppColors.error.withValues(alpha: 0.12),
          AppColors.error,
        ),
      WalletQuotaLimitTone.neutral => (
          colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
          colorScheme.onSurface,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: foreground,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

String walletQuotaRemainingLabel(AppLocalizations l10n, SavedCardsWalletQuota quota) {
  if (quota.hasUnlimitedWallet) return l10n.snrsz;
  if (!quota.canAddMore) return l10n.kotaDoldu;
  if (quota.remaining == 1) return l10n.msg1KartKald;
  return '${quota.remaining} kart kaldı';
}
