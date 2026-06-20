import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../subscriptions/domain/usecases/restore_wallet_purchases.dart';

enum WalletUpgradeSheetResult {
  cancelled,
  purchaseRequested,
  restored,
}

/// Premium cüzdan avantajları; satın alma doğrudan mağaza diyaloğu ile yapılır.
class WalletUpgradeSheet extends StatelessWidget {
  const WalletUpgradeSheet({
    super.key,
    required this.restoreWalletPurchases,
  });

  final RestoreWalletPurchases restoreWalletPurchases;

  static Future<WalletUpgradeSheetResult?> show(
    BuildContext context, {
    required RestoreWalletPurchases restoreWalletPurchases,
  }) {
    return showModalBottomSheet<WalletUpgradeSheetResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => WalletUpgradeSheet(
        restoreWalletPurchases: restoreWalletPurchases,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Premium cüzdan',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Daha fazla kişi kartı saklayın ve etkinliklerinizi ölçeklendirin.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _BenefitRow(
              icon: Icons.credit_card_rounded,
              text: 'Sınırsız kart kaydı',
            ),
            const SizedBox(height: 10),
            _BenefitRow(
              icon: Icons.event_rounded,
              text: 'Sınırsız etkinlik grubu organizasyonu',
            ),
            const SizedBox(height: 10),
            _BenefitRow(
              icon: Icons.edit_note_rounded,
              text: 'Sınırsız elle ve fotoğrafla kart ekleme',
            ),
            const SizedBox(height: 10),
            _BenefitRow(
              icon: Icons.qr_code_scanner_rounded,
              text: 'QR ve kart ID ile hızlı ekleme',
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Premium\'a geç',
              onPressed: () {
                Navigator.of(context).pop(
                  WalletUpgradeSheetResult.purchaseRequested,
                );
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                final restored = await restoreWalletPurchases();
                if (!context.mounted) return;
                if (restored) {
                  Navigator.of(context).pop(WalletUpgradeSheetResult.restored);
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Geri yüklenecek satın alım bulunamadı.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Satın alımları geri yükle'),
            ),
            const SizedBox(height: 4),
            Text(
              'App Store / Play Store üzerinden güvenli ödeme.',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 22, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
