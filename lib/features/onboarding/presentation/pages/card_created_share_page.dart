import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/business_card_qr_panel.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/onboarding_card_draft.dart';

/// Kart oluşturulduktan sonra QR ve kart ID gösteren başarı ekranı.
class CardCreatedSharePage extends StatelessWidget {
  const CardCreatedSharePage({
    super.key,
    required this.draft,
  });

  final OnboardingCardDraft draft;

  static Future<void> open(
    BuildContext context, {
    required OnboardingCardDraft draft,
  }) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CardCreatedSharePage(draft: draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final cardId = draft.cardId?.trim() ?? '';
    final hasValidId = CardIdGenerator.isValid(cardId);

    return CardenceScaffold(
      appBar: CardenceAppBar(
        title: l10n.cardCreatedShareTitle,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.cardCreatedShareHeadline,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.cardCreatedShareSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (hasValidId)
                        BusinessCardQrPanel(
                          qrData: jsonEncode({'id': cardId}),
                          cardId: cardId,
                          hint: l10n.scanQrToSaveCard,
                        )
                      else
                        Text(
                          l10n.kartIdOluturulamadLtfenTekrar,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                label: l10n.cardCreatedShareContinue,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
