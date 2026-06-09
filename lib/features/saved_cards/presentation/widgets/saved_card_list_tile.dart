import 'package:flutter/material.dart';

import '../../domain/entities/saved_card.dart';

/// Kaydedilen kartlar ekranındaki liste satırı.
class SavedCardListTile extends StatelessWidget {
  const SavedCardListTile({
    super.key,
    required this.card,
    this.onTap,
    this.selected,
    this.selectable = false,
  });

  final SavedCard card;
  final VoidCallback? onTap;
  final bool? selected;
  final bool selectable;

  static String titleFor(SavedCard card) {
    final name = card.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Kart ${card.cardId}';
  }

  static String? subtitleFor(SavedCard card) {
    final parts = <String>[
      if (card.company?.trim().isNotEmpty == true) card.company!.trim(),
      if (card.title?.trim().isNotEmpty == true) card.title!.trim(),
    ];
    if (parts.isEmpty) return null;
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = titleFor(card);
    final subtitle = subtitleFor(card);
    final isSelected = selected == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: selectable && isSelected
          ? colorScheme.primaryContainer.withValues(alpha: 0.35)
          : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            title.isNotEmpty ? title[0].toUpperCase() : '?',
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle),
        trailing: selectable
            ? Icon(
                isSelected
                    ? Icons.check_circle_rounded
                    : Icons.circle_outlined,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              )
            : Icon(
                Icons.chevron_right_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
        onTap: onTap,
      ),
    );
  }
}
