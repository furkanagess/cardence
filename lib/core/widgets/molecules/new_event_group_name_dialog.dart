import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';

import '../atoms/custom_button.dart';
import '../atoms/custom_text_field.dart';

/// Yeni etkinlik grubu adı girişi; girilen metni döndürür veya iptal edilirse null.
class NewEventGroupNameDialog extends StatefulWidget {
  const NewEventGroupNameDialog({
    super.key,
    required this.existingNames,
  });

  final List<String> existingNames;

  static bool isDuplicateName(String name, List<String> existingNames) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    return existingNames
        .any((existing) => existing.trim().toLowerCase() == normalized);
  }

  static Future<String?> show(
    BuildContext context, {
    required List<String> existingNames,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => NewEventGroupNameDialog(existingNames: existingNames),
    );
  }

  @override
  State<NewEventGroupNameDialog> createState() =>
      _NewEventGroupNameDialogState();
}

class _NewEventGroupNameDialogState extends State<NewEventGroupNameDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_clearErrorOnEdit);
  }

  void _clearErrorOnEdit() {
    if (_errorText == null) return;
    setState(() => _errorText = null);
  }

  @override
  void dispose() {
    _controller.removeListener(_clearErrorOnEdit);
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Etkinlik adı boş olamaz');
      return;
    }
    if (NewEventGroupNameDialog.isDuplicateName(name, widget.existingNames)) {
      setState(() => _errorText = 'Bu isimde bir etkinlik grubu zaten var');
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.yeniEtkinlikGrubu),
      content: CustomTextField(
        controller: _controller,
        labelText: context.l10n.etkinlikAd,
        hintText: context.l10n.rnWebSummit2026,
        errorText: _errorText,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.iptal),
        ),
        CustomButton(
          label: context.l10n.ekle,
          onPressed: _submit,
          fullWidth: false,
        ),
      ],
    );
  }
}
