import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Yetenek alanı: metin kutusu + "+" ile yetenek ekleme, chip'lerde "-" ile silme.
/// [value] virgülle ayrılmış yetenekler; [onChanged] güncel string ile çağrılır.
class SkillsChipInput extends StatefulWidget {
  const SkillsChipInput({
    super.key,
    this.value,
    required this.onChanged,
    this.label = 'Yetenekler',
    this.hintText = 'Yetenek ekle (örn. Flutter)',
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;
  final String hintText;

  /// Virgülle ayrılmış string'i trim'lenmiş, boş olmayan liste yapar.
  static List<String> _parse(String? s) {
    if (s == null || s.trim().isEmpty) return [];
    return s
        .split(RegExp(r'[,،،\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  static String _join(List<String> list) => list.join(', ');

  @override
  State<SkillsChipInput> createState() => _SkillsChipInputState();
}

class _SkillsChipInputState extends State<SkillsChipInput> {
  late List<String> _items;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _items = SkillsChipInput._parse(widget.value);
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(SkillsChipInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _items = SkillsChipInput._parse(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_items.contains(text)) {
      _controller.clear();
      setState(() {});
      return;
    }
    _items = List.from(_items)..add(text);
    _controller.clear();
    widget.onChanged(SkillsChipInput._join(_items));
    setState(() {});
  }

  void _remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items = List.from(_items)..removeAt(index);
    widget.onChanged(_items.isEmpty ? null : SkillsChipInput._join(_items));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.label.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                widget.label,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    prefixIcon: const Icon(Icons.workspace_premium_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _add,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.add,
                      color: AppColors.textOnPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_items.length, (index) {
                final skill = _items[index];
                return Chip(
                  deleteIcon: Icon(
                    Icons.remove_circle_outline,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onDeleted: () => _remove(index),
                  backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
                  side: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                  label: Text(skill),
                  labelStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}
