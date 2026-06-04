import 'package:flutter/material.dart';

import '../../domain/saved_cards_wallet_limits.dart';
import '../../domain/usecases/upgrade_wallet_plan.dart';

/// Premium paket simülasyonu (yerel); gerçek ödeme entegrasyonu için yer tutucu.
class WalletUpgradeSheet extends StatelessWidget {
  const WalletUpgradeSheet({
    super.key,
    required this.upgradeWalletPlan,
  });

  final UpgradeWalletPlan upgradeWalletPlan;

  static Future<bool?> show(
    BuildContext context, {
    required UpgradeWalletPlan upgradeWalletPlan,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => WalletUpgradeSheet(upgradeWalletPlan: upgradeWalletPlan),
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
              text:
                  '${SavedCardsWalletLimits.premiumMaxCards} karta kadar kayıt',
            ),
            const SizedBox(height: 10),
            _BenefitRow(
              icon: Icons.event_rounded,
              text: 'Sınırsız etkinlik grubu organizasyonu',
            ),
            const SizedBox(height: 10),
            _BenefitRow(
              icon: Icons.qr_code_scanner_rounded,
              text: 'QR ve kart ID ile hızlı ekleme',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await upgradeWalletPlan();
                if (!context.mounted) return;
                Navigator.of(context).pop(true);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Premium\'u etkinleştir (demo)'),
            ),
            const SizedBox(height: 8),
            Text(
              'Gerçek uygulamada App Store / Play Store üzerinden satın alınır.',
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
