import 'package:flutter/material.dart';

import '../../validation/app_validators.dart';
import 'comma_separated_chip_input.dart';

/// Yetenek alanı: metin kutusu + "+" ile yetenek ekleme, chip'lerde "-" ile silme.
/// [value] virgülle ayrılmış yetenekler; [onChanged] güncel string ile çağrılır.
class SkillsChipInput extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return CommaSeparatedChipInput(
      label: label,
      value: value,
      hintText: hintText,
      prefixIcon: Icons.workspace_premium_outlined,
      canAddItem: AppValidators.isValidSkillDraft,
      onChanged: onChanged,
    );
  }
}
