import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import '../../domain/usecases/add_saved_card.dart';

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
        _showError('Bu kart zaten cüzdanınızda.');
      case AddSavedCardLimitReached():
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
    if (id.isEmpty) return 'Kart ID girin';
    if (!CardIdGenerator.isValid(id)) {
      return 'Kart ID tam 6 haneli sayı olmalıdır';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CardenceScaffold(
      appBar: const CardenceAppBar(title: 'Kart ID ile ekle'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Text(
              'Paylaşılan kart kimliğini girin. Bilgiler sunucudaki güncel kartvizitten alınır.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
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
                labelText: 'Kart ID',
                hintText: '482917',
                prefixIcon: const Icon(Icons.badge_outlined),
                maxLength: CardIdGenerator.length,
              ),
              textInputAction: TextInputAction.done,
              autocorrect: false,
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Cüzdana ekle',
              onPressed: _submit,
              isLoading: _submitting,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
