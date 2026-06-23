import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';
import '../../domain/saved_cards_wallet_limits.dart';
import 'wallet_quota_shared.dart';

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
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                        'Cüzdan kotanız',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quota.isPremium
                            ? 'Premium ile tüm limitler kalktı'
                            : 'Ücretsiz plandaki haklarınız',
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
            _LimitsSection(quota: quota, isDemoMode: isDemoMode),
            if (isDemoMode) ...[
              const SizedBox(height: 12),
              _HintCard(
                icon: Icons.lightbulb_outline_rounded,
                message:
                    'Şu an örnek kartlar görüyorsunuz. İlk kartınızı eklediğinizde gerçek kotanız burada görünür.',
                tone: _HintTone.neutral,
              ),
            ] else if (atLimit) ...[
              const SizedBox(height: 12),
              _HintCard(
                icon: Icons.info_outline_rounded,
                message:
                    'Kayıtlı kart limitiniz doldu. Premium ile sınırsız kart saklayabilir ve manuel / fotoğrafla eklemeye devam edebilirsiniz.',
                tone: _HintTone.warning,
              ),
            ],
            if (!quota.isPremium && onUpgradeTap != null) ...[
              const SizedBox(height: 20),
              CustomButton(
                label: 'Cardence Pro ol',
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
    required this.isDemoMode,
  });

  final SavedCardsWalletQuota quota;
  final bool isDemoMode;

  @override
  Widget build(BuildContext context) {
    final usedWallet = isDemoMode ? 0 : quota.usedCount;
    final savedCardsAtLimit = !quota.isPremium && !quota.canAddMore && !isDemoMode;
    final savedCardsNearLimit = !quota.isPremium && quota.isNearLimit && !savedCardsAtLimit;
    final manualLabel = quota.isPremium
        ? 'Sınırsız'
        : quota.canAddManualSavedCard
            ? '1 deneme'
            : 'Premium gerekli';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WalletQuotaLimitRow(
          icon: Icons.credit_card_outlined,
          title: 'Kayıtlı kartlar',
          valueLabel: quota.hasUnlimitedWallet
              ? 'Sınırsız'
              : '$usedWallet / ${quota.maxCards}',
          subtitle: isDemoMode
              ? 'Henüz kart eklenmedi'
              : walletQuotaRemainingLabel(quota),
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
          title: 'Kendi kartlarım',
          valueLabel: quota.isPremium
              ? '${quota.businessCardCount} / ${quota.maxBusinessCards}'
              : '${quota.businessCardCount} / ${SavedCardsWalletLimits.freeMaxOwnBusinessCards}',
          subtitle: quota.canAddBusinessCard
              ? 'Yeni kart oluşturabilirsiniz'
              : 'Kart limitine ulaşıldı',
          tone: quota.canAddBusinessCard
              ? WalletQuotaLimitTone.neutral
              : WalletQuotaLimitTone.error,
        ),
        const SizedBox(height: 10),
        WalletQuotaLimitRow(
          icon: Icons.folder_outlined,
          title: 'Etkinlik grupları',
          valueLabel: quota.hasUnlimitedEventGroups
              ? 'Sınırsız'
              : '${quota.eventGroupCount} / ${quota.maxEventGroups}',
          subtitle: quota.hasUnlimitedEventGroups
              ? 'İstediğiniz kadar grup oluşturun'
              : quota.canAddEventGroup
                  ? '${quota.maxEventGroups - quota.eventGroupCount} grup hakkı kaldı'
                  : 'Grup limitine ulaşıldı',
          tone: quota.hasUnlimitedEventGroups
              ? WalletQuotaLimitTone.success
              : quota.canAddEventGroup
                  ? WalletQuotaLimitTone.neutral
                  : WalletQuotaLimitTone.error,
        ),
        const SizedBox(height: 10),
        WalletQuotaLimitRow(
          icon: Icons.document_scanner_outlined,
          title: 'Manuel & fotoğraf ekleme',
          valueLabel: manualLabel,
          subtitle: quota.isPremium
              ? 'İstediğiniz kadar ekleyin'
              : 'Ücretsiz planda sınırlı deneme',
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

enum _HintTone { neutral, warning }

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
