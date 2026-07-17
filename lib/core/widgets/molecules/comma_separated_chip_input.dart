import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../utils/skills_format.dart';
import '../atoms/custom_text_field.dart';

/// Virgülle ayrılmış değerler için chip girişi (yetenek, etkinlik vb.).
class CommaSeparatedChipInput extends StatefulWidget {
  const CommaSeparatedChipInput({
    super.key,
    this.value,
    required this.onChanged,
    required this.canAddItem,
    this.label = '',
    this.hintText = '',
    this.prefixIcon = Icons.label_outline,
    this.chipIcon,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final bool Function(String text) canAddItem;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final IconData? chipIcon;

  @override
  State<CommaSeparatedChipInput> createState() =>
      _CommaSeparatedChipInputState();
}

class _CommaSeparatedChipInputState extends State<CommaSeparatedChipInput> {
  late List<String> _items;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _items = SkillsFormat.parse(widget.value);
    _controller = TextEditingController();
    _controller.addListener(_onDraftChanged);
  }

  void _onDraftChanged() => setState(() {});

  bool get _canAdd {
    final text = _controller.text.trim();
    if (!widget.canAddItem(text)) return false;
    return !_items.contains(text);
  }

  @override
  void didUpdateWidget(CommaSeparatedChipInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _items = SkillsFormat.parse(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onDraftChanged);
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    if (!_canAdd) return;
    final text = _controller.text.trim();
    _items = List.from(_items)..add(text);
    _controller.clear();
    widget.onChanged(SkillsFormat.join(_items));
    setState(() {});
  }

  void _remove(int index) {
    if (index < 0 || index >= _items.length) return;
    _items = List.from(_items)..removeAt(index);
    widget.onChanged(
      _items.isEmpty ? null : SkillsFormat.join(_items),
    );
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
                child: CustomTextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  hintText: widget.hintText,
                  prefixIcon: Icon(widget.prefixIcon),
                  textInputAction: TextInputAction.done,
                  onSubmitted: _canAdd ? (_) => _add() : null,
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: _canAdd
                    ? AppColors.primary
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _canAdd ? _add : null,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.add,
                      color: _canAdd
                          ? AppColors.textOnPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_items.isNotEmpty) ...[
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final chipMaxWidth = constraints.maxWidth;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    return ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: chipMaxWidth),
                      child: Chip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        avatar: widget.chipIcon != null
                            ? Icon(
                                widget.chipIcon,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              )
                            : null,
                        deleteIcon: Icon(
                          Icons.remove_circle_outline,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onDeleted: () => _remove(index),
                        backgroundColor: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.6),
                        side: BorderSide(
                          color: colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        label: Text(
                          item,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                        labelStyle: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
