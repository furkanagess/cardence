import 'package:flutter/material.dart';
import '../../l10n/app_l10n.dart';
import '../../l10n/l10n_extensions.dart';

import '../../validation/app_validators.dart';
import 'comma_separated_chip_input.dart';

/// Yetenek alanı: metin kutusu + "+" ile yetenek ekleme, chip'lerde "-" ile silme.
/// [value] virgülle ayrılmış yetenekler; [onChanged] güncel string ile çağrılır.
class SkillsChipInput extends StatelessWidget {
  const SkillsChipInput({
    super.key,
    this.value,
    required this.onChanged,
    this.label,
    this.hintText,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String? label;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final resolvedLabel = label ?? AppL10n.yetenekler(context.l10n);
    final resolvedHint = hintText ?? AppL10n.addSkillHint(context.l10n);

    return CommaSeparatedChipInput(
      label: resolvedLabel,
      value: value,
      hintText: resolvedHint,
      prefixIcon: Icons.workspace_premium_outlined,
      canAddItem: AppValidators.isValidSkillDraft,
      onChanged: onChanged,
    );
  }
}
