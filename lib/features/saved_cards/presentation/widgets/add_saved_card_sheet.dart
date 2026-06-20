import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/saved_cards_wallet_quota.dart';

/// Kart ekleme yöntemi seçimi.
enum AddSavedCardMethod {
  manualEntry,
  physicalScan,
  cardId,
  openPaywall,
}

/// Manuel giriş, fotoğraf veya kart ID ile ekleme alt sayfası.
class AddSavedCardSheet extends StatelessWidget {
  const AddSavedCardSheet({
    super.key,
    required this.quota,
    required this.canAdd,
    required this.canAddManualSavedCard,
  });

  final SavedCardsWalletQuota quota;
  final bool canAdd;
  final bool canAddManualSavedCard;

  static Future<AddSavedCardMethod?> show(
    BuildContext context, {
    required SavedCardsWalletQuota quota,
    required bool canAdd,
    required bool canAddManualSavedCard,
  }) {
    return showModalBottomSheet<AddSavedCardMethod>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddSavedCardSheet(
        quota: quota,
        canAdd: canAdd,
        canAddManualSavedCard: canAddManualSavedCard,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kart ekle',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              canAdd
                  ? (quota.hasUnlimitedWallet
                      ? 'Sınırsız kart ekleyebilirsiniz.'
                      : '${quota.remaining} kart daha ekleyebilirsiniz.')
                  : 'Cüzdanınız dolu. Paket yükselterek sınırı artırabilirsiniz.',
              style: textTheme.bodyMedium?.copyWith(
                color: canAdd
                    ? colorScheme.onSurfaceVariant
                    : AppColors.warning,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            _MethodTile(
              icon: Icons.edit_note_rounded,
              title: 'Bilgileri elle gir',
              subtitle: quota.manualEntryMethodSubtitle,
              enabled: canAdd && canAddManualSavedCard,
              premiumLocked: !canAddManualSavedCard,
              onTap: canAdd && canAddManualSavedCard
                  ? () =>
                      Navigator.of(context).pop(AddSavedCardMethod.manualEntry)
                  : !canAddManualSavedCard
                      ? () => Navigator.of(context).pop(
                            AddSavedCardMethod.openPaywall,
                          )
                      : null,
            ),
            const SizedBox(height: 10),
            _MethodTile(
              icon: Icons.photo_camera_outlined,
              title: 'Kartvizit fotoğrafla',
              subtitle: quota.photoScanMethodSubtitle,
              enabled: canAdd && canAddManualSavedCard,
              premiumLocked: !canAddManualSavedCard,
              onTap: canAdd && canAddManualSavedCard
                  ? () =>
                      Navigator.of(context).pop(AddSavedCardMethod.physicalScan)
                  : !canAddManualSavedCard
                      ? () => Navigator.of(context).pop(
                            AddSavedCardMethod.openPaywall,
                          )
                      : null,
            ),
            const SizedBox(height: 10),
            _MethodTile(
              icon: Icons.badge_outlined,
              title: 'Kart ID ile ekle',
              subtitle: '6 haneli özel kimlik ile ekle',
              enabled: canAdd,
              onTap: canAdd
                  ? () => Navigator.of(context).pop(AddSavedCardMethod.cardId)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  const _MethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.onTap,
    this.premiumLocked = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;
  final bool premiumLocked;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: enabled
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: enabled ? colorScheme.onPrimary : disabledColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? colorScheme.onSurface
                            : disabledColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                enabled
                    ? Icons.chevron_right_rounded
                    : premiumLocked
                        ? Icons.workspace_premium_outlined
                        : Icons.lock_outline,
                color: enabled
                    ? colorScheme.onSurfaceVariant
                    : premiumLocked
                        ? colorScheme.primary
                        : disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
