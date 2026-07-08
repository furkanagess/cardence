import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_meta_formatter.dart';
import 'event_group_detail_loading_shimmer.dart';

/// Detay ekranı kapak yüksekliği.
double eventGroupDetailCoverHeight(BuildContext context) {
  final height = MediaQuery.sizeOf(context).height;
  return (height * 0.36).clamp(260.0, 340.0);
}

/// Bilgi paneli ile kapak arasındaki bindirme.
const double eventGroupDetailCoverOverlap = 24;

/// Etkinlik detay kapak görseli.
class EventGroupDetailCover extends StatelessWidget {
  const EventGroupDetailCover({
    super.key,
    required this.group,
  });

  final EventGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = group.photoUrl?.trim().isNotEmpty == true;

    return SizedBox(
      height: eventGroupDetailCoverHeight(context),
      width: double.infinity,
      child: _CoverSection(
        hasPhoto: hasPhoto,
        photoUrl: group.photoUrl,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
    );
  }
}

/// Kapak üzerindeki başlık ve meta bilgiler.
class EventGroupDetailHeroOverlay extends StatelessWidget {
  const EventGroupDetailHeroOverlay({
    super.key,
    required this.group,
  });

  final EventGroup group;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = EventGroupMetaFormatter.formatHeroDateTime(
      group.startAt,
      endAt: group.endAt,
      locale: locale,
    );
    final location = group.location?.trim();

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 56),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              group.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textOnPrimary,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            if (dateText.isNotEmpty)
              _HeroMetaRow(
                icon: Icons.calendar_today_outlined,
                label: dateText,
              ),
            if (location != null && location.isNotEmpty) ...[
              const SizedBox(height: 6),
              _HeroMetaRow(
                icon: Icons.location_on_outlined,
                label: location,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroMetaRow extends StatelessWidget {
  const _HeroMetaRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textOnPrimary.withValues(alpha: 0.92),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textOnPrimary.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
          ),
        ),
      ],
    );
  }
}

/// Kapak altı kaydırılabilir içerik gövdesi.
class EventGroupDetailScrollContent extends StatefulWidget {
  const EventGroupDetailScrollContent({
    super.key,
    required this.group,
    required this.linkedCardCount,
    this.inviteCount = 0,
    this.aboutMaxLines = 2,
    this.loadingLinkedCards = false,
    this.onAddCard,
    this.cardsSection,
  });

  final EventGroup group;
  final int linkedCardCount;
  final int inviteCount;
  final int aboutMaxLines;
  final bool loadingLinkedCards;
  final VoidCallback? onAddCard;
  final Widget? cardsSection;

  @override
  State<EventGroupDetailScrollContent> createState() =>
      _EventGroupDetailScrollContentState();
}

class _EventGroupDetailScrollContentState
    extends State<EventGroupDetailScrollContent> {
  bool _aboutExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final description = widget.group.description?.trim();
    final hasDescription = description != null && description.isNotEmpty;
    final showExpandAction =
        hasDescription && !_aboutExpanded && description.length > 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasDescription) ...[
          Text(
            context.l10n.eventAboutSectionLabel.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
            maxLines: _aboutExpanded ? null : widget.aboutMaxLines,
            overflow: _aboutExpanded ? null : TextOverflow.ellipsis,
          ),
          if (showExpandAction)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: colorScheme.primary,
                ),
                onPressed: () => setState(() => _aboutExpanded = true),
                child: Text(
                  context.l10n.eventShowMore,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            )
          else if (_aboutExpanded)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => setState(() => _aboutExpanded = false),
                child: Text(context.l10n.kapat),
              ),
            ),
          const SizedBox(height: 22),
        ],
        if (widget.loadingLinkedCards)
          const EventGroupDetailStatChipRowShimmer()
        else
          EventGroupDetailStatChipRow(
            linkedCardCount: widget.linkedCardCount,
            inviteCount: widget.inviteCount,
          ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.eventGroupCardsSectionTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
            if (widget.onAddCard != null)
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  foregroundColor: colorScheme.primary,
                ),
                onPressed: widget.onAddCard,
                child: Text(
                  context.l10n.eventAddCardPlus,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.cardsSection != null) widget.cardsSection!,
      ],
    );
  }
}

/// Yuvarlatılmış üst köşeli kaydırılabilir panel sarmalayıcısı.
class EventGroupDetailScrollPanel extends StatelessWidget {
  const EventGroupDetailScrollPanel({
    super.key,
    required this.child,
    this.bottomPadding = 0,
  });

  final Widget child;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 22, 20, bottomPadding),
        child: child,
      ),
    );
  }
}

class EventGroupDetailStatChipRow extends StatelessWidget {
  const EventGroupDetailStatChipRow({
    super.key,
    required this.linkedCardCount,
    required this.inviteCount,
  });

  final int linkedCardCount;
  final int inviteCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _StatChip(
            icon: Icons.people_outline_rounded,
            label: context.l10n.eventDetailCardsChip(linkedCardCount),
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          if (inviteCount > 0) ...[
            const SizedBox(width: 10),
            _StatChip(
              icon: Icons.mail_outline_rounded,
              label: context.l10n.eventDetailInvitesChip(inviteCount),
              colorScheme: colorScheme,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(
          alpha: isDark ? 0.35 : 0.45,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Üstte yarı saydam daire içinde geri / menü butonu.
class EventGroupDetailOverlayIconButton extends StatelessWidget {
  const EventGroupDetailOverlayIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.textPrimary.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.textOnPrimary),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _CoverSection extends StatelessWidget {
  const _CoverSection({
    required this.hasPhoto,
    this.photoUrl,
    required this.colorScheme,
    required this.isDark,
  });

  final bool hasPhoto;
  final String? photoUrl;
  final ColorScheme colorScheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    if (hasPhoto) {
      return Stack(
        fit: StackFit.expand,
        children: [
          AuthenticatedNetworkImage(
            imageUrl: photoUrl!.trim(),
            fit: BoxFit.cover,
            errorBuilder: (_) => _PlaceholderCover(colorScheme: colorScheme),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.textPrimary.withValues(alpha: 0.12),
                  AppColors.textPrimary.withValues(alpha: isDark ? 0.72 : 0.62),
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
        ],
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.primary.withValues(alpha: 0.45),
                  AppColors.textPrimary.withValues(alpha: 0.85),
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.55),
                  AppColors.textPrimary.withValues(alpha: 0.78),
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 56,
          color: AppColors.textOnPrimary.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  const _PlaceholderCover({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.event_rounded,
        size: 48,
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
    );
  }
}
