import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/premium_owner_badge.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
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

  static String? contactHintFor(SavedCard card) {
    if (card.phone?.trim().isNotEmpty == true) return card.phone!.trim();
    if (card.linkedin?.trim().isNotEmpty == true) return card.linkedin!.trim();
    if (card.website?.trim().isNotEmpty == true) return card.website!.trim();
    return null;
  }

  static IconData contactIconFor(SavedCard card) {
    if (card.phone?.trim().isNotEmpty == true) {
      return Icons.phone_outlined;
    }
    if (card.linkedin?.trim().isNotEmpty == true) {
      return Icons.link_rounded;
    }
    return Icons.language_rounded;
  }

  static Color? _parseHexColor(String? hex) {
    if (hex == null || hex.trim().isEmpty) return null;
    var value = hex.trim();
    if (value.startsWith('#')) value = value.substring(1);
    if (value.length == 6) value = 'FF$value';
    if (value.length != 8) return null;
    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) return null;
    return Color(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final title = titleFor(card);
    final subtitle = subtitleFor(card);
    final contactHint = contactHintFor(card);
    final isSelected = selected == true;
    final accentColor =
        _parseHexColor(card.backgroundColor) ?? AppColors.primary;
    final groupCount = card.linkedEventGroupIds.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selectable && isSelected
                ? AppColors.primary
                : (isDark ? AppColors.outlineDark : AppColors.outlineVariant),
            width: selectable && isSelected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ColoredBox(
                  color: accentColor,
                  child: const SizedBox(width: 4),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileAvatar(
                          photoUrl: card.photoUrl,
                          displayName: title,
                          size: 52,
                          circular: true,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (card.isOwnerPremium) ...[
                                    const PremiumOwnerBadge(size: 18),
                                    const SizedBox(width: 6),
                                  ],
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (contactHint != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      contactIconFor(card),
                                      size: 14,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        contactHint,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (groupCount > 0) ...[
                                const SizedBox(height: 8),
                                _SavedCardMetaChip(
                                  icon: Icons.folder_outlined,
                                  label: groupCount == 1
                                      ? '1 grup'
                                      : '$groupCount grup',
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          selectable
                              ? (isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined)
                              : Icons.chevron_right_rounded,
                          color: selectable
                              ? (isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedCardMetaChip extends StatelessWidget {
  const _SavedCardMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
