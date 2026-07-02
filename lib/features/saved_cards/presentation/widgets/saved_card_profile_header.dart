import 'package:flutter/material.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/premium_owner_badge.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/saved_card_preview_colors.dart';

/// LinkedIn tarzı profil başlığı: kapak, avatar, isim ve özet bilgiler.
class SavedCardProfileHeader extends StatelessWidget {
  const SavedCardProfileHeader({
    super.key,
    required this.card,
    required this.displayName,
    this.locationText,
    this.metaText,
    this.onWebsiteTap,
    this.onLinkedInTap,
  });

  final SavedCard card;
  final String displayName;
  final String? locationText;
  final String? metaText;
  final VoidCallback? onWebsiteTap;
  final VoidCallback? onLinkedInTap;

  static const double bannerHeight = 132;
  static const double avatarSize = 96;
  static const double avatarOverlap = 48;

  Color _bannerColor(BuildContext context) {
    final custom = card.previewBackgroundColor;
    if (custom != null) return custom;

    final scheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.82),
      AppColors.secondary,
    );
  }

  Color _bannerAccent(BuildContext context) {
    final custom = card.previewAccentColor;
    if (custom != null) return custom.withValues(alpha: 0.35);

    return AppColors.textOnPrimary.withValues(alpha: 0.12);
  }

  Widget _buildAvatar(BuildContext context) {
    final avatar = ProfileAvatar(
      photoUrl: card.photoUrl,
      displayName: displayName,
      size: avatarSize,
      circular: true,
    );

    final bordered = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 4,
        ),
      ),
      child: avatar,
    );

    return bordered;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bannerColor = _bannerColor(context);
    final title = card.title?.trim();
    final company = card.company?.trim();
    final website = card.website?.trim();
    final linkedin = card.linkedin?.trim();
    final hasWebsite = website != null && website.isNotEmpty;
    final hasLinkedIn = linkedin != null && linkedin.isNotEmpty;

    return ColoredBox(
      color: colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: bannerHeight,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        bannerColor,
                        Color.alphaBlend(_bannerAccent(context), bannerColor),
                      ],
                    ),
                  ),
                ),
              ),
              if (card.isOwnerPremium)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: PremiumOwnerBadge(size: 28),
                ),
              Positioned(
                left: 16,
                bottom: -avatarOverlap,
                child: _buildAvatar(context),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, avatarOverlap + 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                if (title != null && title.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ],
                if (company != null && company.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    company,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
                if (locationText != null && locationText!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    locationText!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (hasWebsite || hasLinkedIn) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      if (hasWebsite)
                        _ProfileLinkChip(
                          label: _linkLabel(website),
                          onTap: onWebsiteTap,
                        ),
                      if (hasLinkedIn)
                        _ProfileLinkChip(
                          label: context.l10n.linkedin,
                          onTap: onLinkedInTap,
                        ),
                    ],
                  ),
                ],
                if (metaText != null && metaText!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    metaText!,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.linkedInBrand,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
        ],
      ),
    );
  }

  static String _linkLabel(String url) {
    var label = url.trim();
    if (label.startsWith('https://')) label = label.substring(8);
    if (label.startsWith('http://')) label = label.substring(7);
    if (label.startsWith('www.')) label = label.substring(4);
    final slash = label.indexOf('/');
    if (slash > 0) label = label.substring(0, slash);
    if (label.length > 28) {
      return '${label.substring(0, 25)}...';
    }
    return label;
  }
}

class _ProfileLinkChip extends StatelessWidget {
  const _ProfileLinkChip({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.linkedInBrand,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: AppColors.linkedInBrand,
            ),
          ],
        ),
      ),
    );
  }
}

String? savedCardProfileLocationText(SavedCard card) {
  final parts = <String>[
    if (card.city?.trim().isNotEmpty == true) card.city!.trim(),
    if (card.country?.trim().isNotEmpty == true) card.country!.trim(),
  ];
  if (parts.isNotEmpty) return parts.join(', ');

  final address = card.address?.trim();
  if (address != null && address.isNotEmpty) return address;
  return null;
}

String savedCardProfileMetaText(BuildContext context, SavedCard card) {
  final savedAt = card.savedAt;
  if (savedAt == null) {
    return '${AppL10n.kart(context.l10n)} · ${card.cardId}';
  }

  final dt = DateTime.fromMillisecondsSinceEpoch(savedAt);
  const months = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];
  final dateLabel = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  return '${AppL10n.savedAtLabel(context.l10n, dateLabel)} · ${card.cardId}';
}
