import 'dart:convert';

import 'package:flutter/material.dart';

import '../../l10n/l10n_extensions.dart';
import '../../utils/card_id_generator.dart';
import 'business_card_qr_panel.dart';

/// Kart paylaşımı: QR + kopyalanabilir kart ID.
class CardShareOptionsSheet extends StatelessWidget {
  const CardShareOptionsSheet({
    super.key,
    required this.cardId,
  });

  final String cardId;

  static Future<void> show(
    BuildContext context, {
    required String cardId,
  }) {
    final trimmedId = cardId.trim();
    if (!CardIdGenerator.isValid(trimmedId)) {
      return Future.value();
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => CardShareOptionsSheet(cardId: trimmedId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.kartPayla,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.scanQrToSaveCard,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            BusinessCardQrPanel(
              qrData: jsonEncode({'id': cardId}),
              cardId: cardId,
            ),
          ],
        ),
      ),
    );
  }
}
