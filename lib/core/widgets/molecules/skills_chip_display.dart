import 'package:flutter/material.dart';

import '../../utils/skills_format.dart';

/// Yetenekleri etkinlik grubu chip'leriyle aynı mantıkta Wrap içinde listeler.
class SkillsChipDisplay extends StatelessWidget {
  const SkillsChipDisplay({
    super.key,
    this.skillsRaw,
    this.skills,
    this.onSkillTap,
  }) : assert(skillsRaw != null || skills != null);

  final String? skillsRaw;
  final List<String>? skills;
  final ValueChanged<String>? onSkillTap;

  List<String> get _items => skills ?? SkillsFormat.parse(skillsRaw);

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final skill in items)
          ActionChip(
            label: Text(skill),
            onPressed:
                onSkillTap == null ? null : () => onSkillTap!(skill),
            backgroundColor: colorScheme.surfaceContainerHighest,
            labelStyle: textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
      ],
    );
  }
}
