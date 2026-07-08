import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/media/media_image_size.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/contact_launcher.dart';
import '../../../../core/widgets/atoms/card_watermark.dart';
import '../../../../core/widgets/atoms/premium_owner_badge.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../../../core/widgets/molecules/card_preview_action_strip_colors.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/saved_card_preview_colors.dart';

/// Kaydedilen kartlar — fiziksel kartvizit hissine yakın önizleme.
class SavedCardRichTile extends StatelessWidget {
  const SavedCardRichTile({
    super.key,
    required this.card,
    required this.accentColor,
    this.onDetailTap,
    this.onContactTap,
    this.trailingGap = true,
  });

  final SavedCard card;
  final Color accentColor;
  final VoidCallback? onDetailTap;
  final ValueChanged<String>? onContactTap;
  final bool trailingGap;

  static const double _cornerRadius = 14;
  static const double _accentStripeWidth = 6;

  /// Yığın önizlemesi — ISO kartvizitten daha kısa.
  static const double stackCardAspectRatio = 2.0;

  static double stackTileHeightFor(double cardWidth) =>
      cardWidth / stackCardAspectRatio;

  static final List<Color> fallbackAccents = [
    AppColors.primary,
    AppColors.success,
    const Color(0xFFE07A2F),
  ];

  static Color accentFor(SavedCard card, int index) {
    return card.previewAccentColor ??
        fallbackAccents[index % fallbackAccents.length];
  }

  static String titleFor(SavedCard card) {
    final name = card.displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Kart ${card.cardId}';
  }

  List<BoxShadow> _cardShadows(bool isLightSurface) {
    final shadowBase =
        AppColors.textPrimary.withValues(alpha: isLightSurface ? 0.14 : 0.38);
    return [
      BoxShadow(
        color: shadowBase.withValues(alpha: 0.45),
        blurRadius: 22,
        offset: const Offset(0, 10),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: shadowBase,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: shadowBase.withValues(alpha: 0.35),
        blurRadius: 2,
        offset: const Offset(0, 1),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final title = titleFor(card);
    final jobTitle = card.title?.trim();
    final company = card.company?.trim();
    final surfaceColor =
        card.previewBackgroundColor ?? theme.colorScheme.surface;
    final isLightSurface = surfaceColor.computeLuminance() > 0.5;
    final primaryTextColor =
        isLightSurface ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final secondaryTextColor =
        isLightSurface ? AppColors.textSecondary : AppColors.textSecondaryDark;
    final actionPalette = CardPreviewActionStripColors.resolve(
      cardSurface: surfaceColor,
      accentColor: accentColor,
    );
    final borderColor = (isLightSurface
            ? AppColors.outlineVariant
            : AppColors.outlineDark)
        .withValues(alpha: 0.55);
    final footerColor = Color.alphaBlend(
      accentColor.withValues(alpha: isLightSurface ? 0.08 : 0.16),
      surfaceColor,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: trailingGap ? 14 : 0),
      child: AspectRatio(
        aspectRatio: stackCardAspectRatio,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cornerRadius),
            boxShadow: _cardShadows(isLightSurface),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_cornerRadius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: borderColor),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.alphaBlend(
                      AppColors.surfaceLight.withValues(alpha: 0.22),
                      surfaceColor,
                    ),
                    surfaceColor,
                    Color.alphaBlend(
                      AppColors.textPrimary.withValues(alpha: 0.04),
                      surfaceColor,
                    ),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ColoredBox(
                    color: accentColor,
                    child: const SizedBox(width: _accentStripeWidth),
                  ),
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 20, 78, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor.withValues(alpha: 0.85),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.textPrimary
                                          .withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: ProfileAvatar(
                                    photoUrl: card.photoUrl,
                                    displayName: title,
                                    size: 68,
                                    circular: false,
                                    displaySize: MediaImageSize.medium,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: textTheme.titleLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: primaryTextColor,
                                              letterSpacing: -0.35,
                                              height: 1.1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (jobTitle != null &&
                                        jobTitle.isNotEmpty) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        jobTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                    if (company != null &&
                                        company.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: accentColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 7),
                                          Expanded(
                                            child: Text(
                                              company.toUpperCase(),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  textTheme.labelMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.8,
                                                color: accentColor.withValues(
                                                  alpha: isLightSurface
                                                      ? 0.92
                                                      : 1,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                              ),
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                color: footerColor,
                                border: Border(
                                  top: BorderSide(
                                    color:
                                        borderColor.withValues(alpha: 0.75),
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 9, 14, 11),
                          child: Row(
                            children: [
                              _ContactIconButton(
                                icon: Icons.mail_outline_rounded,
                                enabled:
                                    card.email?.trim().isNotEmpty == true,
                                accentColor: actionPalette.iconColor,
                                chipBorder: actionPalette.chipBorder,
                                onTap: card.email?.trim().isNotEmpty == true
                                    ? () {
                                        onContactTap?.call('email');
                                        ContactLauncher.launchEmail(
                                          context,
                                          card.email!.trim(),
                                        );
                                      }
                                    : null,
                                tooltip: context.l10n.ePosta,
                              ),
                              const SizedBox(width: 7),
                              _ContactIconButton(
                                icon: Icons.phone_outlined,
                                enabled:
                                    card.phone?.trim().isNotEmpty == true,
                                accentColor: actionPalette.iconColor,
                                chipBorder: actionPalette.chipBorder,
                                onTap: card.phone?.trim().isNotEmpty == true
                                    ? () {
                                        onContactTap?.call('phone');
                                        ContactLauncher.launchPhone(
                                          context,
                                          card.phone!.trim(),
                                        );
                                      }
                                    : null,
                                tooltip: context.l10n.telefon,
                              ),
                              if (card.website?.trim().isNotEmpty == true) ...[
                                const SizedBox(width: 7),
                                _ContactIconButton(
                                  icon: Icons.language_rounded,
                                  enabled: true,
                                  accentColor: actionPalette.iconColor,
                                  chipBorder: actionPalette.chipBorder,
                                  onTap: () {
                                    onContactTap?.call('website');
                                    ContactLauncher.launchWebUrl(
                                      context,
                                      card.website!.trim(),
                                    );
                                  },
                                  tooltip: context.l10n.webSitesi,
                                ),
                              ],
                              const SizedBox(width: 7),
                              _ContactIconButton(
                                icon: Icons.ios_share_rounded,
                                enabled: card.cardId.trim().isNotEmpty,
                                accentColor: actionPalette.iconColor,
                                chipBorder: actionPalette.chipBorder,
                                onTap: card.cardId.trim().isNotEmpty
                                    ? () => _copyCardId(
                                        context, card.cardId.trim())
                                    : null,
                                tooltip: context.l10n.kartId2,
                              ),
                              const Spacer(),
                              if (onDetailTap != null)
                                _ContactIconButton(
                                  icon: Icons.north_east_rounded,
                                  enabled: true,
                                  accentColor: accentColor,
                                  chipBorder: actionPalette.chipBorder,
                                  onTap: onDetailTap,
                                  tooltip: context.l10n.kartDetay,
                                ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                        Positioned(
                          top: 6,
                          right: 2,
                          child: CardenceCardCornerWatermark(
                            surfaceColor: surfaceColor,
                            size: 88,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyCardId(BuildContext context, String cardId) async {
    await Clipboard.setData(ClipboardData(text: cardId));
    if (!context.mounted) return;
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.kartIdKopyaland)),
    );
  }
}

class _ContactIconButton extends StatelessWidget {
  const _ContactIconButton({
    required this.icon,
    required this.enabled,
    this.accentColor,
    this.chipBorder,
    this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final bool enabled;
  final Color? accentColor;
  final Color? chipBorder;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final resolvedAccent = accentColor ?? AppColors.primary;
    final iconColor =
        enabled ? resolvedAccent : resolvedAccent.withValues(alpha: 0.35);
    final borderColor = enabled
        ? (chipBorder ?? resolvedAccent.withValues(alpha: 0.4))
        : AppColors.outlineVariant;

    final button = SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: borderColor),
          shape: const CircleBorder(),
          foregroundColor: iconColor,
          backgroundColor: enabled
              ? resolvedAccent.withValues(alpha: 0.06)
              : Colors.transparent,
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );

    if (tooltip == null || tooltip!.isEmpty) return button;

    return Tooltip(message: tooltip!, child: button);
  }
}
