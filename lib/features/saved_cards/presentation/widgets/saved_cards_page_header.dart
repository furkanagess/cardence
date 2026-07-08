import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import 'wallet_quota_detail_sheet.dart';

/// Kaydedilen kartlar üst başlığı: marka ve cüzdan kotası.
class SavedCardsPageHeader extends StatelessWidget {
  const SavedCardsPageHeader({
    super.key,
    required this.quota,
    this.onUpgradeTap,
  });

  final SavedCardsWalletQuota quota;
  final VoidCallback? onUpgradeTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleColor = CardenceAppBar.resolveForeground(context);

    return CardenceAppBarRegion(
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppConstants.appName,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.4,
                color: titleColor,
              ),
            ),
          ),
          if (!quota.hasUnlimitedWallet)
            _WalletQuotaBadge(
              used: quota.usedCount,
              max: quota.maxCards,
              atLimit: !quota.canAddMore && !quota.isPremium,
              onTap: () => WalletQuotaDetailSheet.show(
                context,
                quota: quota,
                onUpgradeTap: onUpgradeTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _WalletQuotaBadge extends StatelessWidget {
  const _WalletQuotaBadge({
    required this.used,
    required this.max,
    required this.atLimit,
    required this.onTap,
  });

  final int used;
  final int max;
  final bool atLimit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = atLimit
        ? AppColors.error.withValues(alpha: isDark ? 0.18 : 0.1)
        : AppColors.primary;
    final foreground =
        atLimit ? AppColors.error : AppColors.textOnPrimary;
    final borderColor = atLimit
        ? AppColors.error.withValues(alpha: 0.35)
        : AppColors.primaryDark.withValues(alpha: isDark ? 0.45 : 0.25);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                  '$used/$max',
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
    );
  }
}
