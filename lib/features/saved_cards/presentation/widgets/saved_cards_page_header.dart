import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import 'wallet_quota_detail_sheet.dart';

/// Kaydedilen kartlar AppBar'ında cüzdan kotası rozeti.
class SavedCardsWalletQuotaBadge extends StatelessWidget {
  const SavedCardsWalletQuotaBadge({
    super.key,
    required this.quota,
    this.onUpgradeTap,
  });

  final SavedCardsWalletQuota quota;
  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    if (quota.hasUnlimitedWallet) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final atLimit = !quota.canAddMore && !quota.isPremium;
    final background = atLimit
        ? AppColors.error.withValues(alpha: isDark ? 0.18 : 0.1)
        : AppColors.primary;
    final foreground = atLimit ? AppColors.error : AppColors.textOnPrimary;
    final borderColor = atLimit
        ? AppColors.error.withValues(alpha: 0.35)
        : AppColors.primaryDark.withValues(alpha: isDark ? 0.45 : 0.25);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => WalletQuotaDetailSheet.show(
              context,
              quota: quota,
              onUpgradeTap: onUpgradeTap,
            ),
            borderRadius: BorderRadius.circular(10),
            child: Ink(
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor),
                boxShadow: atLimit
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary
                              .withValues(alpha: isDark ? 0.28 : 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 11, 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.credit_card_rounded,
                      size: 16,
                      color: foreground,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${quota.usedCount}/${quota.maxCards}',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                        color: foreground,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
