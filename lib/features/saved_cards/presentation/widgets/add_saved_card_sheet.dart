import 'package:flutter/material.dart';

import '../../domain/entities/saved_cards_wallet_quota.dart';

/// Kart ekleme yöntemi seçimi.
enum AddSavedCardMethod {
  qrScan,
  cardId,
}

/// QR veya kart ID ile ekleme alt sayfası.
class AddSavedCardSheet extends StatelessWidget {
  const AddSavedCardSheet({
    super.key,
    required this.quota,
    required this.canAdd,
  });

  final SavedCardsWalletQuota quota;
  final bool canAdd;

  static Future<AddSavedCardMethod?> show(
    BuildContext context, {
    required SavedCardsWalletQuota quota,
    required bool canAdd,
  }) {
    return showModalBottomSheet<AddSavedCardMethod>(
      context: context,
      showDragHandle: true,
      builder: (context) => AddSavedCardSheet(quota: quota, canAdd: canAdd),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Kart ekle',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              canAdd
                  ? '${quota.remaining} kart daha ekleyebilirsiniz.'
                  : 'Cüzdanınız dolu. Paket yükselterek sınırı artırabilirsiniz.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _MethodTile(
              icon: Icons.qr_code_scanner_rounded,
              title: 'QR kod okut',
              subtitle: 'Karşı tarafın paylaştığı Cardence QR\'ını tarayın',
              enabled: canAdd,
              onTap: canAdd
                  ? () => Navigator.of(context).pop(AddSavedCardMethod.qrScan)
                  : null,
            ),
            const SizedBox(height: 10),
            _MethodTile(
              icon: Icons.badge_outlined,
              title: 'Kart ID veya kod yapıştır',
              subtitle: 'Kart kimliği girin veya QR içeriğini yapıştırın',
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
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: enabled
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(
                    alpha: enabled ? 0.12 : 0.06,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: enabled
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
