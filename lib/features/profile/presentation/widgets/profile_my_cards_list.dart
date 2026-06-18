import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';

/// Profilde kullanıcının kendi kartlarından biri.
class ProfileMyCardTile extends StatelessWidget {
  const ProfileMyCardTile({
    super.key,
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final OnboardingCardDraft card;
  final bool selected;
  final VoidCallback onTap;

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
    final accentColor =
        _parseHexColor(card.backgroundColor) ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected
            ? colorScheme.primaryContainer.withValues(alpha: 0.35)
            : colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.outlineDark : AppColors.outlineVariant),
            width: selected ? 1.5 : 1,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        ProfileAvatar(
                          photoUrl: card.photoUrl,
                          displayName: card.listTitle,
                          size: 44,
                          circular: true,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.listTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (card.listSubtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  card.listSubtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          selected
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          color: selected
                              ? colorScheme.primary
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

/// Profilde tüm kartların listesi.
class ProfileMyCardsList extends StatelessWidget {
  const ProfileMyCardsList({
    super.key,
    required this.cards,
    required this.selectedIndex,
    required this.onCardSelected,
  });

  final List<OnboardingCardDraft> cards;
  final int selectedIndex;
  final ValueChanged<int> onCardSelected;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            cards.length == 1 ? '1 kart' : '${cards.length} kart',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(cards.length, (index) {
            return ProfileMyCardTile(
              card: cards[index],
              selected: index == selectedIndex,
              onTap: () => onCardSelected(index),
            );
          }),
        ],
      ),
    );
  }
}
