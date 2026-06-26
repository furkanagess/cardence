import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/saved_cards_wallet_limits.dart';
import 'wallet_quota_shared.dart';

class WalletQuotaDetailSheet extends StatelessWidget {
  const WalletQuotaDetailSheet({
    super.key,
    required this.quota,
    this.onUpgradeTap,
  });

  final SavedCardsWalletQuota quota;
  final VoidCallback? onUpgradeTap;

  static Future<void> show(
    BuildContext context, {
    required SavedCardsWalletQuota quota,
    VoidCallback? onUpgradeTap,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => WalletQuotaDetailSheet(
        quota: quota,
        onUpgradeTap: onUpgradeTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final atLimit = !quota.canAddMore && !quota.isPremium;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.czdanKotanz,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quota.isPremium
                            ? context.l10n.quotaPremiumAllLimitsRemoved
                            : context.l10n.quotaFreePlanRights,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                WalletQuotaPlanChip(isPremium: quota.isPremium),
              ],
            ),
            const SizedBox(height: 20),
            _LimitsSection(quota: quota),
            if (atLimit) ...[
              const SizedBox(height: 12),
              _HintCard(
                icon: Icons.info_outline_rounded,
                message:
                    context.l10n.kaytlKartLimitinizDolduPremium,
                tone: _HintTone.warning,
              ),
            ],
            if (!quota.isPremium && onUpgradeTap != null) ...[
              const SizedBox(height: 20),
              CustomButton(
                label: context.l10n.cardenceProOl,
                icon: Icons.workspace_premium_rounded,
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

class _LimitsSection extends StatelessWidget {
  const _LimitsSection({
    required this.quota,
  });

  final SavedCardsWalletQuota quota;

  @override
  Widget build(BuildContext context) {
    final usedWallet = quota.usedCount;
    final savedCardsAtLimit = !quota.isPremium && !quota.canAddMore;
    final savedCardsNearLimit = !quota.isPremium && quota.isNearLimit && !savedCardsAtLimit;
    final manualLabel = quota.isPremium
        ? context.l10n.snrsz
        : quota.canAddManualSavedCard
            ? context.l10n.oneTrial
            : context.l10n.premiumRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WalletQuotaLimitRow(
          icon: Icons.credit_card_outlined,
          title: context.l10n.kaytlKartlar,
          valueLabel: quota.hasUnlimitedWallet
              ? context.l10n.snrsz
              : '$usedWallet / ${quota.maxCards}',
          subtitle: walletQuotaRemainingLabel(context.l10n, quota),
          tone: quota.hasUnlimitedWallet
              ? WalletQuotaLimitTone.success
              : savedCardsAtLimit
                  ? WalletQuotaLimitTone.error
                  : savedCardsNearLimit
                      ? WalletQuotaLimitTone.warning
                      : WalletQuotaLimitTone.neutral,
        ),
        const SizedBox(height: 10),
        WalletQuotaLimitRow(
          icon: Icons.badge_outlined,
          title: context.l10n.kendiKartlarm,
          valueLabel: quota.isPremium
              ? '${quota.businessCardCount} / ${quota.maxBusinessCards}'
              : '${quota.businessCardCount} / ${SavedCardsWalletLimits.freeMaxOwnBusinessCards}',
          subtitle: quota.canAddBusinessCard
              ? context.l10n.canCreateNewCard
              : context.l10n.cardLimitReached,
          tone: quota.canAddBusinessCard
              ? WalletQuotaLimitTone.neutral
              : WalletQuotaLimitTone.error,
        ),
        const SizedBox(height: 10),
        WalletQuotaLimitRow(
          icon: Icons.folder_outlined,
          title: context.l10n.etkinlikGruplar,
          valueLabel: quota.hasUnlimitedEventGroups
              ? context.l10n.snrsz
              : '${quota.eventGroupCount} / ${quota.maxEventGroups}',
          subtitle: quota.hasUnlimitedEventGroups
              ? context.l10n.createUnlimitedGroups
              : quota.canAddEventGroup
                  ? context.l10n.eventGroupsRemaining(
                      quota.maxEventGroups - quota.eventGroupCount,
                    )
                  : context.l10n.groupLimitReached,
          tone: quota.hasUnlimitedEventGroups
              ? WalletQuotaLimitTone.success
              : quota.canAddEventGroup
                  ? WalletQuotaLimitTone.neutral
                  : WalletQuotaLimitTone.error,
        ),
        const SizedBox(height: 10),
        WalletQuotaLimitRow(
          icon: Icons.document_scanner_outlined,
          title: context.l10n.manuelFotorafEkleme,
          valueLabel: manualLabel,
          subtitle: quota.isPremium
              ? context.l10n.addUnlimitedManualPhoto
              : context.l10n.limitedTrialOnFreePlan,
          tone: quota.isPremium
              ? WalletQuotaLimitTone.success
              : quota.canAddManualSavedCard
                  ? WalletQuotaLimitTone.neutral
                  : WalletQuotaLimitTone.error,
        ),
      ],
    );
  }
}

enum _HintTone { warning }

class _HintCard extends StatelessWidget {
  const _HintCard({
    required this.icon,
    required this.message,
    required this.tone,
  });

  final IconData icon;
  final String message;
  final _HintTone tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isWarning = tone == _HintTone.warning;
    final background = isWarning
        ? AppColors.warning.withValues(alpha: 0.1)
        : Theme.of(context).colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5);
    final foreground =
        isWarning ? AppColors.warning : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: foreground),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodySmall?.copyWith(
                color: foreground,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
