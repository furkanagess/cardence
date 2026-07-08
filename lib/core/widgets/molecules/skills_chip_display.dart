import 'package:flutter/material.dart';

import '../../utils/skills_format.dart';

/// Yetenekleri etkinlik grubu chip'leriyle aynı mantıkta Wrap içinde listeler.
class SkillsChipDisplay extends StatelessWidget {
  const SkillsChipDisplay({
    super.key,
    this.skillsRaw,
    this.skills,
    this.onSkillTap,
    this.chipBackgroundColor,
    this.chipLabelColor,
  }) : assert(skillsRaw != null || skills != null);

  final String? skillsRaw;
  final List<String>? skills;
  final ValueChanged<String>? onSkillTap;
  final Color? chipBackgroundColor;
  final Color? chipLabelColor;

  List<String> get _items => skills ?? SkillsFormat.parse(skillsRaw);

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final chipBg =
        chipBackgroundColor ?? colorScheme.surfaceContainerHighest;
    final chipFg = chipLabelColor ?? colorScheme.onSurface;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final skill in items)
          ActionChip(
            label: Text(skill),
            onPressed:
                onSkillTap == null ? null : () => onSkillTap!(skill),
            backgroundColor: chipBg,
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: chipFg,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
          ),
      ],
    );
  }
}
