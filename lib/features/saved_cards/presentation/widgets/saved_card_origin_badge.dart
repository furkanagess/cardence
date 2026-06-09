import 'package:flutter/material.dart';

import '../../domain/entities/saved_card_origin.dart';

/// Manuel ve Cardence kartlarını ayırt eden küçük rozet.
class SavedCardOriginBadge extends StatelessWidget {
  const SavedCardOriginBadge({
    super.key,
    required this.origin,
    this.compact = false,
  });

  final SavedCardOrigin origin;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isManual = origin == SavedCardOrigin.manual;

    final background = isManual
        ? colorScheme.secondaryContainer
        : colorScheme.primaryContainer;
    final foreground = isManual
        ? colorScheme.onSecondaryContainer
        : colorScheme.onPrimaryContainer;
    final icon = isManual ? Icons.edit_note_rounded : Icons.badge_rounded;
    final label = isManual ? 'Manuel' : 'Cardence';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 14 : 16, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: (compact
                      ? textTheme.labelSmall
                      : textTheme.labelMedium)
                  ?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
