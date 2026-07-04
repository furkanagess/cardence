import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/authenticated_network_image.dart';
import '../../domain/entities/event_group.dart';
import '../helpers/event_group_meta_formatter.dart';
import 'event_group_meta_chip.dart';
import 'event_group_status_badge.dart';

/// Detay ekranı kapak yüksekliği (daha kısa, ~5:16).
double eventGroupDetailCoverHeight(BuildContext context) {
  return MediaQuery.sizeOf(context).width * 5 / 16;
}

/// Bilgi paneli ile kapak arasındaki bindirme.
const double eventGroupDetailCoverOverlap = 16;

/// Etkinlik detay kapak görseli; scroll sırasında arka planda sabit kalır.
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

/// Kapak altındaki sabitlenen bilgi paneli (durum, tarih, konum, açıklama).
class EventGroupDetailPinnedInfoSection extends StatefulWidget {
  const EventGroupDetailPinnedInfoSection({
    super.key,
    required this.group,
    this.aboutMaxLines = 4,
    this.aboutExpanded = false,
    this.onAboutExpandedChanged,
  });

  final EventGroup group;
  final int aboutMaxLines;
  final bool aboutExpanded;
  final ValueChanged<bool>? onAboutExpandedChanged;

  @override
  State<EventGroupDetailPinnedInfoSection> createState() =>
      _EventGroupDetailPinnedInfoSectionState();
}

class _EventGroupDetailPinnedInfoSectionState
    extends State<EventGroupDetailPinnedInfoSection> {
  bool _aboutExpanded = false;

  @override
  void initState() {
    super.initState();
    _aboutExpanded = widget.aboutExpanded;
  }

  @override
  void didUpdateWidget(covariant EventGroupDetailPinnedInfoSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.aboutExpanded != widget.aboutExpanded) {
      _aboutExpanded = widget.aboutExpanded;
    }
    if (oldWidget.group.id != widget.group.id ||
        oldWidget.group.description != widget.group.description) {
      _aboutExpanded = widget.aboutExpanded;
    }
  }

  void _toggleAboutExpanded() {
    final next = !_aboutExpanded;
    setState(() => _aboutExpanded = next);
    widget.onAboutExpandedChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateText = EventGroupMetaFormatter.formatRange(
      widget.group.startAt,
      widget.group.endAt,
    );
    final location = widget.group.location?.trim();
    final description = widget.group.description?.trim();
    final showExpandAction = description != null &&
        description.isNotEmpty &&
        !_aboutExpanded &&
        description.length > 120;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.06 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            EventGroupStatusBadge(status: widget.group.status),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (dateText.isNotEmpty)
                  EventGroupMetaChip(
                    icon: Icons.calendar_month_outlined,
                    label: dateText,
                  ),
                if (location != null && location.isNotEmpty)
                  EventGroupMetaChip(
                    icon: Icons.location_on_outlined,
                    label: location,
                  ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                context.l10n.eventAboutSection,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
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
                    ),
                    onPressed: _toggleAboutExpanded,
                    child: Text(context.l10n.devam),
                  ),
                )
              else if (_aboutExpanded &&
                  widget.onAboutExpandedChanged != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: _toggleAboutExpanded,
                    child: Text(context.l10n.kapat),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kaydırılabilir kart listesinin üst başlığı.
class EventGroupDetailLinkedCardsHeader extends StatelessWidget {
  const EventGroupDetailLinkedCardsHeader({
    super.key,
    required this.linkedCardCount,
  });

  final int linkedCardCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.eventLinkedCardsSection(linkedCardCount),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

/// [EventGroupDetailPinnedInfoSection] yüksekliğini bildirir.
class EventGroupDetailSizeReporter extends StatefulWidget {
  const EventGroupDetailSizeReporter({
    super.key,
    required this.onHeightChanged,
    required this.child,
  });

  final ValueChanged<double> onHeightChanged;
  final Widget child;

  @override
  State<EventGroupDetailSizeReporter> createState() =>
      _EventGroupDetailSizeReporterState();
}

class _EventGroupDetailSizeReporterState
    extends State<EventGroupDetailSizeReporter> {
  Size? _lastSize;

  void _reportSize() {
    if (!mounted) return;
    final size = context.size;
    if (size == null || size == _lastSize) return;
    _lastSize = size;
    widget.onHeightChanged(size.height);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  @override
  void didUpdateWidget(covariant EventGroupDetailSizeReporter oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportSize());
    return widget.child;
  }
}

/// Detay ekranında sabitlenen bilgi paneli için sliver delegate.
class EventGroupDetailPinnedInfoDelegate
    extends SliverPersistentHeaderDelegate {
  EventGroupDetailPinnedInfoDelegate({
    required this.height,
    required this.child,
  });

  final double height;
  final Widget child;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: height,
      child: ClipRect(
        child: Material(
          color: Colors.transparent,
          elevation: overlapsContent ? 1 : 0,
          shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
          child: Align(
            alignment: Alignment.topCenter,
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant EventGroupDetailPinnedInfoDelegate oldDelegate) {
    return oldDelegate.height != height;
  }
}

/// Kapak altındaki bilgi paneli (durum, tarih, konum, açıklama).
class EventGroupDetailInfoSection extends StatelessWidget {
  const EventGroupDetailInfoSection({
    super.key,
    required this.group,
    this.linkedCardCount,
  });

  final EventGroup group;
  final int? linkedCardCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EventGroupDetailPinnedInfoSection(group: group),
        if (linkedCardCount != null)
          EventGroupDetailLinkedCardsHeader(linkedCardCount: linkedCardCount!),
      ],
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
                  Colors.transparent,
                  AppColors.textPrimary.withValues(alpha: isDark ? 0.55 : 0.35),
                ],
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
                  AppColors.primary.withValues(alpha: 0.25),
                  AppColors.surfaceVariantDark,
                ]
              : [
                  AppColors.primary.withValues(alpha: 0.12),
                  AppColors.surfaceVariant,
                ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 56,
          color: colorScheme.primary.withValues(alpha: 0.45),
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
