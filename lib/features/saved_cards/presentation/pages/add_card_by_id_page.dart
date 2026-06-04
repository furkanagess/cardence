import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/card_share_payload.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/card_share_payload_to_saved_card.dart';
import '../../domain/usecases/add_saved_card.dart';

/// Kart ID veya QR JSON içeriği ile cüzdana kart ekleme.
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
  final _jsonController = TextEditingController();
  bool _useJson = false;
  bool _submitting = false;

  @override
  void dispose() {
    _cardIdController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    SavedCard? card;
    if (_useJson) {
      try {
        final map = jsonDecode(_jsonController.text.trim()) as Map<String, dynamic>;
        final payload = CardSharePayload.fromJson(map);
        if (payload == null) {
          _showError('Geçersiz kart kodu. "id" alanı zorunludur.');
          setState(() => _submitting = false);
          return;
        }
        card = payload.toSavedCard();
      } catch (_) {
        _showError('JSON okunamadı. QR içeriğini olduğu gibi yapıştırın.');
        setState(() => _submitting = false);
        return;
      }
    } else {
      card = SavedCard(
        cardId: _cardIdController.text.trim(),
        savedAt: DateTime.now().millisecondsSinceEpoch,
      );
    }

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
    if (_useJson) return null;
    final id = value?.trim() ?? '';
    if (id.isEmpty) return 'Kart ID girin';
    if (id.length < 8) return 'En az 8 karakter olmalı';
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(id)) {
      return 'Yalnızca harf, rakam, tire ve alt çizgi kullanın';
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
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text('Kart ID'),
                  icon: Icon(Icons.tag_rounded, size: 18),
                ),
                ButtonSegment(
                  value: true,
                  label: Text('QR kodu'),
                  icon: Icon(Icons.code_rounded, size: 18),
                ),
              ],
              selected: {_useJson},
              onSelectionChanged: (set) {
                setState(() => _useJson = set.first);
              },
            ),
            const SizedBox(height: 20),
            if (!_useJson) ...[
              Text(
                'Paylaşılan kart kimliğini girin. Tam bilgiler için QR okutmanız önerilir.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardIdController,
                validator: _validateCardId,
                decoration: const InputDecoration(
                  labelText: 'Kart ID',
                  hintText: 'ör. 8f3c2a1b-4d5e-6f7a-8b9c-0d1e2f3a4b5c',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                textInputAction: TextInputAction.done,
                autocorrect: false,
              ),
            ] else ...[
              Text(
                'QR kodun içindeki JSON metnini yapıştırın (Cardence paylaşım formatı).',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jsonController,
                minLines: 5,
                maxLines: 10,
                validator: (v) {
                  if (!_useJson) return null;
                  if (v == null || v.trim().isEmpty) {
                    return 'QR içeriğini yapıştırın';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'QR içeriği (JSON)',
                  hintText: '{"id":"...","n":"Ad Soyad",...}',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                autocorrect: false,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Cüzdana ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
