import 'package:flutter/material.dart';

/// Elle girilen kartlar için rozet yerine alt bilgi satırı.
class ManualEntryCaption extends StatelessWidget {
  const ManualEntryCaption({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final foreground = colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.draw_outlined,
          size: compact ? 14 : 16,
          color: foreground,
        ),
        const SizedBox(width: 6),
        Text(
          'Elle girildi',
          style: (compact ? textTheme.labelSmall : textTheme.labelMedium)
              ?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

/// Detay ekranında elle girilen kartlar için açıklayıcı şerit.
class ManualEntryDetailBanner extends StatelessWidget {
  const ManualEntryDetailBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(
              Icons.draw_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Bu kart elle girildi; Cardence hesabına bağlı değil.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
