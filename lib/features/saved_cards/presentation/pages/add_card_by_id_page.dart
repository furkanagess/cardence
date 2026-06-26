import 'package:flutter/material.dart';
import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import '../../domain/usecases/add_saved_card.dart';
import '../widgets/add_card_ui_helpers.dart';

/// Kart ID ile cüzdana kart ekleme.
class AddCardByIdPage extends StatefulWidget {
  const AddCardByIdPage({
    super.key,
    required this.addSavedCard,
  });

  final AddSavedCard addSavedCard;

  @override
  State<AddCardByIdPage> createState() => _AddCardByIdPageState();
}

class _AddCardByIdPageState extends State<AddCardByIdPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardIdController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _cardIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final card = SavedCard(
      cardId: _cardIdController.text.trim(),
      origin: SavedCardOrigin.cardence,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final result = await widget.addSavedCard(card);
    if (!mounted) return;
    setState(() => _submitting = false);

    switch (result) {
      case AddSavedCardSuccess():
        Navigator.of(context).pop(result);
      case AddSavedCardDuplicate():
        _showError(context.l10n.buKartZatenCzdannzda);
      case AddSavedCardLimitReached():
      case AddSavedCardPremiumRequired():
        Navigator.of(context).pop(result);
      case AddSavedCardInvalidPayload(:final message):
        _showError(message);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String? _validateCardId(String? value) {
    final id = value?.trim() ?? '';
    if (id.isEmpty) return context.l10n.kartIdGirin;
    if (!CardIdGenerator.isValid(id)) {
      return context.l10n.kartIdTam6Haneli;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return CardenceScaffold(
      appBar: CardenceAppBar(title: context.l10n.kartIdIleEkle),
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        Icons.badge_outlined,
                        size: 36,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.paylalanKartKimliiniGirinBilgiler,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    context.l10n.kartId,
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cardIdController,
                    validator: _validateCardId,
                    keyboardType: TextInputType.number,
                    maxLength: CardIdGenerator.length,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(CardIdGenerator.length),
                    ],
                    decoration: CustomTextField.themedDecoration(
                      context,
                      hintText: '000000',
                      prefixIcon: const Icon(Icons.perm_identity_outlined),
                      maxLength: CardIdGenerator.length,
                    ),
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.sadeceSaysalKarakterlerKabulEdilir,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  AddCardTipCard.security(
                    title: context.l10n.gvenliPaylam,
                    text: AppL10n.cardenceDataSecurityMessage(context.l10n),
                  ),
                ],
              ),
            ),
          ),
          AddCardStickyAction(
            label: context.l10n.kartEkle2,
            icon: Icons.add_card_rounded,
            onPressed: _submit,
            isLoading: _submitting,
          ),
        ],
      ),
    );
  }
}
