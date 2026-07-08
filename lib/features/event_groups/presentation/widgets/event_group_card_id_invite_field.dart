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
  static const double _rowHeight = 48;

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: _rowHeight,
                    child: TextField(
                      controller: widget.controller,
                      keyboardType: TextInputType.number,
                      maxLength: CardIdGenerator.length,
                      autocorrect: false,
                      textAlignVertical: TextAlignVertical.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(CardIdGenerator.length),
                      ],
                      decoration: CustomTextField.themedDecoration(
                        context,
                        hintText: '000000',
                        prefixIcon: const Icon(Icons.perm_identity_outlined),
                        maxLength: CardIdGenerator.length,
                      ).copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
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
                  if (_errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _errorText!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            CustomButton.tonal(
              label: context.l10n.ekle,
              icon: Icons.add_rounded,
              onPressed: _tryAdd,
              fullWidth: false,
              height: _rowHeight,
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
