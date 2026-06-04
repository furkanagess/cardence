import 'package:flutter/material.dart';

/// Kişi / iletişim kartı: tema ile uyumlu, profesyonel ve üç boyutlu görünüm.
/// [compact] true olduğunda kartvizit oranında sıkı yerleşim kullanılır.
class PersonInfoCard extends StatelessWidget {
  const PersonInfoCard({
    super.key,
    this.title,
    this.titleSecondary,
    required this.entries,
    this.emptyMessage = 'Henüz bilgi yok',
    this.emptyActionLabel,
    this.onEmptyActionTap,
    this.onNoteEditTap,
    this.compact = false,
    this.fillHeight = false,
    this.accentColor,
    this.backgroundColor,
  });

  /// Kartın üstünde vurgulanan isim / başlık.
  final String? title;
  final String? titleSecondary;

  /// Gösterilecek alanlar: (etiket, değer). Boş değerler gösterilmez.
  final List<({String label, String value})> entries;

  /// Hiç başlık ve entry yoksa gösterilecek metin.
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyActionTap;
  final VoidCallback? onNoteEditTap;

  /// true: kartvizit tarzı, küçük yazı ve az padding.
  final bool compact;

  /// true: dikey alanı doldurur; not alanı üst/alt boşlukları eşitlenir.
  final bool fillHeight;

  /// Kart vurgu rengi (ikonlar vb.). null ise tema primary kullanılır.
  final Color? accentColor;

  /// Kart arka plan rengi. null ise tema surface kullanılır; verilirse metin kontrastı otomatik ayarlanır.
  final Color? backgroundColor;

  /// Arka plan rengine göre okunabilir metin rengi (koyu arka plan → açık metin).
  static Color _onSurfaceForBackground(Color bg) {
    return bg.computeLuminance() > 0.5 ? const Color(0xFF1C1C1C) : const Color(0xFFF5F5F5);
  }

  static Color _onSurfaceVariantForBackground(Color bg) {
    return bg.computeLuminance() > 0.5 ? const Color(0xFF505050) : const Color(0xFFE0E0E0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasSecondaryTitle =
        titleSecondary != null && titleSecondary!.trim().isNotEmpty;
    final visibleEntries =
        compact ? entries.take(3).toList() : entries;
    final hasEntries = visibleEntries.isNotEmpty;

    final surfaceColor = backgroundColor ?? colorScheme.surface;
    final Color onSurface;
    final Color onSurfaceVariant;
    if (accentColor != null) {
      onSurface = accentColor!;
      onSurfaceVariant = Color.alphaBlend(
        accentColor!.withValues(alpha: 0.72),
        surfaceColor,
      );
    } else if (backgroundColor != null) {
      onSurface = _onSurfaceForBackground(surfaceColor);
      onSurfaceVariant = _onSurfaceVariantForBackground(surfaceColor);
    } else {
      onSurface = colorScheme.onSurface;
      onSurfaceVariant = colorScheme.onSurfaceVariant;
    }
    final bool isSurfaceDark = surfaceColor.computeLuminance() < 0.35;

    final radius = compact ? 14.0 : 24.0;
    final paddingH = compact ? 16.0 : 22.0;
    final paddingV = compact ? 14.0 : 24.0;
    final paddingTitleTop = compact ? 14.0 : 26.0;
    final sectionGap = compact ? 12.0 : 14.0;
    final titleBottomGap = fillHeight ? sectionGap : (compact ? 6.0 : 10.0);

    final borderColorSubtle = onSurfaceVariant.withOpacity(0.2);

    // 3D efekt: çok katmanlı gölge (derinlik hissi)
    final shadowOpacity = isSurfaceDark ? 0.5 : 0.18;
    final depth = compact ? 6.0 : 10.0;
    final blurMain = compact ? 20.0 : 28.0;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColorSubtle, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity * 0.4),
            blurRadius: blurMain * 1.2,
            offset: Offset(0, depth * 0.4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity),
            blurRadius: blurMain,
            offset: Offset(0, depth),
            spreadRadius: compact ? -4 : -6,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity * 0.6),
            blurRadius: blurMain * 0.6,
            offset: Offset(0, depth * 0.6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            if (hasTitle) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  paddingH,
                  paddingTitleTop,
                  paddingH,
                  hasEntries ? titleBottomGap : (compact ? 6 : 10),
                ),
                child: RichText(
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    text: title!,
                    style: (compact ? textTheme.titleMedium : textTheme.headlineSmall)?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                      letterSpacing: compact ? 0 : -0.25,
                    ),
                    children: hasSecondaryTitle
                        ? [
                            TextSpan(
                              text: ' • ${titleSecondary!.trim()}',
                              style: (compact ? textTheme.bodySmall : textTheme.bodyMedium)
                                  ?.copyWith(
                                color: onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ]
                        : const [],
                  ),
                ),
              ),
              if (hasEntries)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingH),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: onSurfaceVariant.withOpacity(0.2),
                  ),
                ),
            ],
            if (!hasEntries)
              Padding(
                padding: EdgeInsets.all(paddingH),
                child: (emptyActionLabel != null && onEmptyActionTap != null)
                    ? SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: onEmptyActionTap,
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact ? 12 : 16,
                                  vertical: compact ? 8 : 10,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(emptyActionLabel!),
                            ),
                          ],
                        ),
                      )
                    : Text(
                        emptyMessage,
                        style: (compact ? textTheme.bodySmall : textTheme.bodyLarge)?.copyWith(
                          color: onSurfaceVariant,
                        ),
                      ),
              )
            else if (hasEntries)
              if (fillHeight)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      paddingH,
                      hasTitle ? sectionGap : paddingTitleTop,
                      paddingH,
                      sectionGap,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: visibleEntries
                          .asMap()
                          .entries
                          .map(
                            (entry) => _InfoRow(
                              label: entry.value.label,
                              value: entry.value.value,
                              icon: _iconForLabel(entry.value.label),
                              compact: compact,
                              isLastInGroup:
                                  entry.key == visibleEntries.length - 1,
                              onEditTap: entry.value.label == 'Notlar'
                                  ? onNoteEditTap
                                  : null,
                              accentColor: accentColor ?? onSurface,
                              onSurface: onSurface,
                              onSurfaceVariant: onSurfaceVariant,
                              surfaceColor: surfaceColor,
                              expandVertically:
                                  entry.value.label == 'Notlar' &&
                                  entry.key == visibleEntries.length - 1,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                )
              else
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    paddingH,
                    compact ? 8 : 18,
                    paddingH,
                    compact ? 8 : paddingV,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: visibleEntries
                        .asMap()
                        .entries
                        .map(
                          (entry) => _InfoRow(
                            label: entry.value.label,
                            value: entry.value.value,
                            icon: _iconForLabel(entry.value.label),
                            compact: compact,
                            isLastInGroup:
                                entry.key == visibleEntries.length - 1,
                            onEditTap: entry.value.label == 'Notlar'
                                ? onNoteEditTap
                                : null,
                            accentColor: accentColor ?? onSurface,
                            onSurface: onSurface,
                            onSurfaceVariant: onSurfaceVariant,
                            surfaceColor: surfaceColor,
                          ),
                        )
                        .toList(),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  static IconData? _iconForLabel(String label) {
    switch (label) {
      case 'E-posta':
        return Icons.email_outlined;
      case 'Telefon':
        return Icons.phone_outlined;
      case 'Şirket':
        return Icons.business_outlined;
      case 'Ünvan':
        return Icons.badge_outlined;
      case 'Web sitesi':
      case 'Web':
        return Icons.language;
      case 'LinkedIn':
        return Icons.link;
      case 'Yetenekler':
        return Icons.workspace_premium_outlined;
      case 'Okul':
        return Icons.school_outlined;
      case 'Hakkımda':
        return Icons.person_outline_rounded;
      case 'Notlar':
        return null;
      default:
        return Icons.info_outline_rounded;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.compact = false,
    this.isLastInGroup = false,
    this.onEditTap,
    this.expandVertically = false,
    this.accentColor,
    Color? onSurface,
    Color? onSurfaceVariant,
    required this.surfaceColor,
  })  : onSurface = onSurface ?? const Color(0xFF1C1C1C),
        onSurfaceVariant = onSurfaceVariant ?? const Color(0xFF505050);

  final String label;
  final String value;
  final IconData? icon;
  final bool compact;
  final bool isLastInGroup;
  final VoidCallback? onEditTap;
  final bool expandVertically;
  final Color? accentColor;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceColor;

  bool get _surfaceIsDark => surfaceColor.computeLuminance() < 0.4;

  Color get _iconWrapperColor {
    final base = accentColor ?? onSurface;
    return Color.alphaBlend(base.withOpacity(0.18), surfaceColor);
  }

  Color get _entryBackground {
    final overlay = _surfaceIsDark ? Colors.white : Colors.black;
    final amount = _surfaceIsDark ? 0.12 : 0.04;
    return Color.alphaBlend(overlay.withOpacity(amount), surfaceColor);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final iconColor = accentColor ?? theme.colorScheme.primary;
    final isNote = label == 'Notlar';

    final iconBoxSize = compact ? 26.0 : 34.0;
    final iconSize = compact ? 14.0 : 18.0;

    final row = Padding(
      padding: EdgeInsets.only(
        bottom: isLastInGroup || expandVertically ? 0 : (compact ? 6 : 16),
      ),
      child: Row(
        crossAxisAlignment: expandVertically
            ? CrossAxisAlignment.stretch
            : CrossAxisAlignment.center,
        children: [
          if (icon != null && !isNote) ...[
            SizedBox(
              width: iconBoxSize,
              height: iconBoxSize,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: _iconWrapperColor,
                  borderRadius: BorderRadius.circular(compact ? 10 : 14),
                  border: Border.all(color: iconColor.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: iconSize,
                    color: iconColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: compact ? 10 : 16),
          ],
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: _entryBackground,
                borderRadius: BorderRadius.circular(compact ? 12 : 16),
                border: Border.all(
                  color: onSurfaceVariant.withOpacity(0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_surfaceIsDark ? 0.4 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 10 : 16,
                  vertical: compact ? (isNote ? 8 : 6) : (isNote ? 14 : 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: expandVertically
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            style: (compact
                                    ? textTheme.labelSmall
                                    : textTheme.labelMedium)
                                ?.copyWith(
                              color: onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              letterSpacing: compact ? 0.2 : 0.4,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (onEditTap != null)
                          TextButton(
                            onPressed: onEditTap,
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              minimumSize: const Size(0, 28),
                            ),
                            child: Text(
                              'Duzenle',
                              style: (compact
                                      ? textTheme.labelSmall
                                      : textTheme.labelMedium)
                                  ?.copyWith(
                                color: onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: compact ? 2 : 4),
                    if (expandVertically && isNote)
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            value,
                            style: (compact
                                    ? textTheme.bodySmall
                                    : textTheme.bodyLarge)
                                ?.copyWith(
                              color: onSurface,
                              height: compact ? 1.2 : 1.35,
                            ),
                            maxLines: compact ? 7 : 9,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: isNote ? (compact ? 92 : 118) : 0,
                        ),
                        child: Text(
                          value,
                          style: (compact
                                  ? textTheme.bodySmall
                                  : textTheme.bodyLarge)
                              ?.copyWith(
                            color: onSurface,
                            height: compact ? 1.2 : 1.35,
                          ),
                          maxLines: isNote ? (compact ? 7 : 9) : 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (expandVertically) {
      return Expanded(child: row);
    }
    return row;
  }
}
