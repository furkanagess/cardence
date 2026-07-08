import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/utils/clipboard_feedback.dart';
import '../../../../core/theme/app_colors.dart';
import '../helpers/saved_card_detail_theme.dart';
import '../../../../core/widgets/atoms/premium_owner_badge.dart';
import '../../../../core/widgets/atoms/profile_avatar.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/extensions/saved_card_preview_colors.dart';

/// Profil başlığı: gradient kapak, sol avatar, sağda kart ID.
class SavedCardProfileHeader extends StatelessWidget {
  const SavedCardProfileHeader({
    super.key,
    required this.card,
    required this.displayName,
    this.locationText,
  });

  final SavedCard card;
  final String displayName;
  final String? locationText;

  static const double bannerHeight = 120;
  static const double avatarSize = 88;
  static const double avatarOverlap = 44;

  Color _bannerColor(BuildContext context) {
    final custom = card.previewBackgroundColor;
    if (custom != null) return custom;

    final scheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      scheme.primary.withValues(alpha: 0.88),
      AppColors.secondary,
    );
  }

  Color _bannerAccent(BuildContext context) {
    final custom = card.previewAccentColor;
    if (custom != null) return custom.withValues(alpha: 0.35);

    return AppColors.textOnPrimary.withValues(alpha: 0.14);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bannerColor = _bannerColor(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final title = card.title?.trim();
    final company = card.company?.trim();
    final hasCompany = company != null && company.isNotEmpty;
    final hasTitle = title != null && title.isNotEmpty;
    final hasRole = hasCompany || hasTitle;
    final hasLocation = locationText != null && locationText!.isNotEmpty;
    final hasCardId = card.cardId.isNotEmpty;
    final surfaceColor = SavedCardDetailTheme.surface(context);
    final textPrimary = SavedCardDetailTheme.textPrimary(context);
    final textSecondary = SavedCardDetailTheme.textSecondary(context);
    final chipSurface = SavedCardDetailTheme.chipSurface(context);

    return ColoredBox(
      color: surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                height: bannerHeight + topInset,
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        bannerColor,
                        Color.alphaBlend(_bannerAccent(context), bannerColor),
                      ],
                    ),
                  ),
                ),
              ),
              if (card.isOwnerPremium)
                Positioned(
                  top: topInset + 12,
                  right: 12,
                  child: const PremiumOwnerBadge(size: 28),
                ),
              Positioned(
                left: 20,
                bottom: -avatarOverlap,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: surfaceColor,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: SavedCardDetailTheme.cardShadow(context),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ProfileAvatar(
                    photoUrl: card.photoUrl,
                    displayName: displayName,
                    size: avatarSize,
                    circular: true,
                  ),
                ),
              ),
              if (hasCardId)
                Positioned(
                  right: 20,
                  bottom: -avatarOverlap,
                  height: avatarSize,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _CopyableCardIdPill(
                      cardId: card.cardId,
                      chipSurface: chipSurface,
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, avatarOverlap + 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    height: 1.15,
                    letterSpacing: -0.2,
                  ),
                ),
                if (hasRole) ...[
                  const SizedBox(height: 4),
                  _ProfileRoleLine(
                    company: hasCompany ? company : null,
                    title: hasTitle ? title : null,
                    textSecondary: textSecondary,
                  ),
                ],
                if (hasLocation) ...[
                  const SizedBox(height: 10),
                  _LocationPill(
                    location: locationText!,
                    textSecondary: textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRoleLine extends StatelessWidget {
  const _ProfileRoleLine({
    required this.company,
    required this.title,
    required this.textSecondary,
  });

  final String? company;
  final String? title;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final style = textTheme.bodyMedium?.copyWith(
      color: textSecondary,
      height: 1.35,
    );

    final parts = <String>[
      if (company != null) company!,
      if (title != null) title!,
    ];

    return Text(
      parts.join(' • '),
      style: style,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _CopyableCardIdPill extends StatefulWidget {
  const _CopyableCardIdPill({
    required this.cardId,
    required this.chipSurface,
  });

  final String cardId;
  final Color chipSurface;

  @override
  State<_CopyableCardIdPill> createState() => _CopyableCardIdPillState();
}

class _CopyableCardIdPillState extends State<_CopyableCardIdPill> {
  bool _copied = false;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await copyTextWithClipboardFeedback(context, value: widget.cardId);
    if (!mounted) return;
    _resetTimer?.cancel();
    setState(() => _copied = true);
    _resetTimer = Timer(kClipboardCopyIconDuration, () {
      if (!mounted) return;
      setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: widget.cardId,
      child: Material(
        color: widget.chipSurface,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _copy,
          borderRadius: BorderRadius.circular(999),
          splashColor: AppColors.primary.withValues(alpha: 0.14),
          highlightColor: AppColors.primary.withValues(alpha: 0.08),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.cardId,
                    style: textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      _copied ? Icons.check_rounded : Icons.copy_rounded,
                      key: ValueKey(_copied),
                      size: 14,
                      color: AppColors.primary.withValues(alpha: 0.85),
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
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({
    required this.location,
    required this.textSecondary,
  });

  final String location;
  final Color textSecondary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: textSecondary.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 4),
        Text(
          location,
          style: textTheme.bodySmall?.copyWith(
            color: textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
