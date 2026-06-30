import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../helpers/support_topic_labels.dart';
import '../../domain/entities/support_topic.dart';

class SupportTopicSelector extends StatelessWidget {
  const SupportTopicSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SupportTopic selected;
  final ValueChanged<SupportTopic> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.konu,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SupportTopic.values.map((topic) {
            final isSelected = topic == selected;
            return FilterChip(
              label: Text(supportTopicLabel(context.l10n, topic)),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onChanged(topic),
              labelStyle: textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
              selectedColor: colorScheme.primaryContainer,
              backgroundColor: colorScheme.surfaceContainerHighest,
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.outline.withValues(alpha: 0.35),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
