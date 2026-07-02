import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';

class EventGroupCardIdInviteField extends StatefulWidget {
  const EventGroupCardIdInviteField({
    super.key,
    required this.controller,
    required this.invitedCardIds,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final Set<String> invitedCardIds;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  @override
  State<EventGroupCardIdInviteField> createState() =>
      _EventGroupCardIdInviteFieldState();
}

class _EventGroupCardIdInviteFieldState extends State<EventGroupCardIdInviteField> {
  String? _errorText;

  void _clearErrorOnEdit() {
    if (_errorText == null) return;
    setState(() => _errorText = null);
  }

  void _tryAdd() {
    final cardId = widget.controller.text.trim();
    if (cardId.isEmpty) {
      setState(() => _errorText = context.l10n.kartIdGirin);
      return;
    }
    if (!CardIdGenerator.isValid(cardId)) {
      setState(() => _errorText = context.l10n.kartIdTam6Haneli);
      return;
    }
    if (widget.invitedCardIds.contains(cardId)) {
      widget.controller.clear();
      return;
    }

    setState(() => _errorText = null);
    widget.controller.clear();
    widget.onAdd(cardId);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.kartId,
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                keyboardType: TextInputType.number,
                maxLength: CardIdGenerator.length,
                autocorrect: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(CardIdGenerator.length),
                ],
                decoration: CustomTextField.themedDecoration(
                  context,
                  hintText: '000000',
                  errorText: _errorText,
                  prefixIcon: const Icon(Icons.perm_identity_outlined),
                  maxLength: CardIdGenerator.length,
                ),
                textInputAction: TextInputAction.done,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
                onChanged: (_) => _clearErrorOnEdit(),
                onSubmitted: (_) => _tryAdd(),
              ),
            ),
            const SizedBox(width: 10),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: CustomButton.tonal(
                label: context.l10n.ekle,
                icon: Icons.add_rounded,
                onPressed: _tryAdd,
                fullWidth: false,
              ),
            ),
          ],
        ),
        if (widget.invitedCardIds.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.invitedCardIds
                .map(
                  (cardId) => InputChip(
                    label: Text(cardId),
                    onDeleted: () => widget.onRemove(cardId),
                  ),
                )
                .toList(),
          ),
        ],
        if (widget.invitedCardIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.eventInvitedCardIdsCount(widget.invitedCardIds.length),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
