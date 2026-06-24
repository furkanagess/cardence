import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../theme/app_colors.dart';
import '../../utils/birthday_format.dart';

/// Salt okunur alan; dokunulunca takvimden doğum günü seçilir.
class BirthdayPickerField extends StatefulWidget {
  const BirthdayPickerField({
    super.key,
    required this.label,
    this.value,
    required this.onChanged,
    this.hintText = 'Tarih seçin',
  });

  final String label;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String hintText;

  @override
  State<BirthdayPickerField> createState() => _BirthdayPickerFieldState();
}

class _BirthdayPickerFieldState extends State<BirthdayPickerField> {
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _ensureLocale();
  }

  Future<void> _ensureLocale() async {
    await initializeDateFormatting('tr');
    if (mounted) setState(() => _localeReady = true);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = BirthdayFormat.tryParse(widget.value) ??
        DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: context.l10n.doumGnSein,
      cancelText: context.l10n.iptal,
      confirmText: context.l10n.tamam,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;
    widget.onChanged(BirthdayFormat.toStorage(picked));
    setState(() {});
  }

  void _clear() => widget.onChanged(null);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final displayText = _localeReady ? BirthdayFormat.display(widget.value) : '';
    final hasValue = widget.value != null && widget.value!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(10),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            filled: true,
            fillColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: hasValue
                ? IconButton(
                    tooltip: context.l10n.temizle,
                    onPressed: _clear,
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                : Icon(
                    Icons.calendar_month_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
          ),
          child: Text(
            hasValue ? displayText : widget.hintText,
            style: textTheme.bodyLarge?.copyWith(
              color: hasValue
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
