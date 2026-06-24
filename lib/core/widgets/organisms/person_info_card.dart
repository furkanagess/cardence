import 'package:flutter/material.dart';
import '../../../core/l10n/l10n_extensions.dart';

import '../../utils/card_contact_visibility.dart';
import '../../utils/contact_launcher.dart';
import '../atoms/card_watermark.dart';
import '../atoms/custom_button.dart';
import '../atoms/premium_owner_badge.dart';
import '../atoms/profile_avatar.dart';
import '../molecules/card_back_id_badge.dart';

bool _isNoteLabel(String label) => label == 'Notlar' || label == 'Notes';

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
    this.photoUrl,
    this.showAppLogo = true,
    this.showPremiumBadge = false,
    this.titleRightInset = 0,
    this.bottomRightInset = 0,
    this.compactBackFace = false,
    this.cardId,
    this.showCardIdOnBack = false,
    this.contactEmail,
    this.contactPhone,
    this.contactWebsite,
    this.contactLinkedin,
    this.visibleContactFields = const [],
    this.jobTitle,
  });

  /// Kompakt kartvizit yüzü köşe yarıçapı (flip önizleme vb.).
  static const double compactCardRadius = 18;

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

  /// Kişi profil fotoğrafı URL'si.
  final String? photoUrl;

  /// Başlık satırının sağında Cardence logosu gösterilir.
  final bool showAppLogo;

  /// Premium kart sahibi rozeti (sol üst köşe).
  final bool showPremiumBadge;

  /// Flip butonu gibi üst sağ öğeler için ek sağ boşluk.
  final double titleRightInset;

  /// Flip butonu gibi alt sağ öğeler için ek iç boşluk.
  final double bottomRightInset;

  /// Kompakt kartın arka yüzü: yalnızca Hakkımda içeriği.
  final bool compactBackFace;

  /// Paylaşım / eşleşme için kart kimliği.
  final String? cardId;

  /// Arka yüzde sağ altta Kart ID rozeti.
  final bool showCardIdOnBack;

  /// Alt iletişim satırı (entries dışından).
  final String? contactEmail;
  final String? contactPhone;
  final String? contactWebsite;
  final String? contactLinkedin;

  /// Gösterilecek iletişim anahtarları: email, phone, linkedin, website.
  final List<String> visibleContactFields;

  /// Ünvan; entries'den bağımsız yapısal alan.
  final String? jobTitle;

  /// Arka plan rengine göre okunabilir metin rengi (koyu arka plan → açık metin).
  static Color _onSurfaceForBackground(Color bg) {
    return bg.computeLuminance() > 0.5
        ? const Color(0xFF1C1C1C)
        : const Color(0xFFF5F5F5);
  }

  static Color _onSurfaceVariantForBackground(Color bg) {
    return bg.computeLuminance() > 0.5
        ? const Color(0xFF505050)
        : const Color(0xFFE0E0E0);
  }

  /// Kompakt kartvizit 3D gölge katmanları.
  static List<BoxShadow> compactCardShadows({
    required bool isSurfaceDark,
    required double shadowOpacity,
    required double depth,
    required double blurMain,
  }) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowOpacity * 0.42),
        blurRadius: blurMain * 1.2,
        offset: Offset(0, depth * 0.42),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowOpacity),
        blurRadius: blurMain,
        offset: Offset(0, depth),
        spreadRadius: -5,
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowOpacity * 0.72),
        blurRadius: blurMain * 0.5,
        offset: Offset(0, depth * 0.62),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowOpacity * 0.65),
        blurRadius: blurMain * 0.55,
        offset: Offset(0, depth * 0.55),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: shadowOpacity * 0.28),
        blurRadius: blurMain * 0.35,
        offset: Offset(2, depth * 0.48),
        spreadRadius: -2,
      ),
      if (!isSurfaceDark)
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.55),
          blurRadius: 0,
          offset: const Offset(0, -1),
        ),
    ];
  }

  /// Üstten vurulan ışık / beyaz parlama gradyanı.
  static Widget compactCardTopHighlight(bool isSurfaceDark) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      height: 48,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: isSurfaceDark ? 0.1 : 0.14),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasSecondaryTitle =
        titleSecondary != null && titleSecondary!.trim().isNotEmpty;
    final visibleEntries = compact ? entries.take(3).toList() : entries;
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

    if (compact) {
      return _CompactBusinessCardFace(
        title: title,
        titleSecondary: titleSecondary,
        entries: entries,
        emptyMessage: emptyMessage,
        emptyActionLabel: emptyActionLabel,
        onEmptyActionTap: onEmptyActionTap,
        onNoteEditTap: onNoteEditTap,
        fillHeight: fillHeight,
        backFace: compactBackFace,
        cardId: cardId,
        showCardIdOnBack: showCardIdOnBack,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        contactWebsite: contactWebsite,
        contactLinkedin: contactLinkedin,
        visibleContactFields: visibleContactFields,
        jobTitle: jobTitle,
        accentColor: accentColor,
        backgroundColor: surfaceColor,
        photoUrl: photoUrl,
        showAppLogo: showAppLogo,
        showPremiumBadge: showPremiumBadge,
        titleRightInset: titleRightInset,
        bottomRightInset: bottomRightInset,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
      );
    }

    final radius = 24.0;
    final paddingH = 22.0;
    final paddingV = 24.0;
    final paddingTitleTop = 26.0;
    final sectionGap = 14.0;
    final titleBottomGap = fillHeight ? sectionGap : 10.0;

    final borderColorSubtle = onSurfaceVariant.withOpacity(0.2);

    // 3D efekt: çok katmanlı gölge (derinlik hissi)
    final shadowOpacity = isSurfaceDark ? 0.5 : 0.18;
    const depth = 10.0;
    const blurMain = 28.0;

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
            offset: const Offset(0, depth),
            spreadRadius: -6,
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
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            if (showAppLogo)
              Positioned(
                top: -12,
                right: 8 + titleRightInset,
                child: CardenceCardCornerWatermark(
                  surfaceColor: surfaceColor,
                  compact: false,
                ),
              ),
            if (showPremiumBadge)
              const Positioned(
                top: 10,
                left: 12,
                child: PremiumOwnerBadge(size: 24),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                if (hasTitle) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      paddingH,
                      paddingTitleTop,
                      paddingH + titleRightInset,
                      hasEntries ? titleBottomGap : 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (photoUrl != null &&
                            photoUrl!.trim().isNotEmpty) ...[
                          ProfileAvatar(
                            photoUrl: photoUrl,
                            displayName: title,
                            size: 56,
                          ),
                          const SizedBox(width: 14),
                        ],
                        Expanded(
                          child: RichText(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: title!,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                                letterSpacing: -0.25,
                              ),
                              children: hasSecondaryTitle
                                  ? [
                                      TextSpan(
                                        text: ' • ${titleSecondary!.trim()}',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ]
                                  : const [],
                            ),
                          ),
                        ),
                      ],
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
                    child:
                        (emptyActionLabel != null && onEmptyActionTap != null)
                            ? SizedBox(
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CustomButton.tonal(
                                      label: emptyActionLabel!,
                                      icon: Icons.add_rounded,
                                      onPressed: onEmptyActionTap,
                                      fullWidth: false,
                                      visualDensity: VisualDensity.compact,
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Text(
                                emptyMessage,
                                style: textTheme.bodyLarge?.copyWith(
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
                                  icon: PersonInfoCard._iconForLabel(
                                      entry.value.label),
                                  compact: false,
                                  isLastInGroup:
                                      entry.key == visibleEntries.length - 1,
                                  onEditTap: _isNoteLabel(entry.value.label) ||
                                          entry.value.label == context.l10n.notlar
                                      ? onNoteEditTap
                                      : null,
                                  accentColor: accentColor ?? onSurface,
                                  onSurface: onSurface,
                                  onSurfaceVariant: onSurfaceVariant,
                                  surfaceColor: surfaceColor,
                                  expandVertically: (_isNoteLabel(entry.value.label) ||
                                          entry.value.label ==
                                              context.l10n.notlar) &&
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
                        18,
                        paddingH,
                        paddingV,
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
                                icon: PersonInfoCard._iconForLabel(
                                    entry.value.label),
                                compact: false,
                                isLastInGroup:
                                    entry.key == visibleEntries.length - 1,
                                onEditTap: _isNoteLabel(entry.value.label) ||
                                        entry.value.label == context.l10n.notlar
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
      case 'Pozisyon':
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
    final isNote =
        _isNoteLabel(label) || label == context.l10n.notlar;

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
                    color:
                        Colors.black.withOpacity(_surfaceIsDark ? 0.4 : 0.05),
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
                  mainAxisSize:
                      expandVertically ? MainAxisSize.max : MainAxisSize.min,
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
                              context.l10n.duzenle,
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

/// ISO kartvizit oranında, sade tipografi ile kompakt kart yüzü.
class _CompactBusinessCardFace extends StatelessWidget {
  const _CompactBusinessCardFace({
    required this.entries,
    required this.emptyMessage,
    required this.fillHeight,
    required this.backgroundColor,
    required this.showAppLogo,
    this.showPremiumBadge = false,
    required this.titleRightInset,
    this.bottomRightInset = 0,
    required this.onSurface,
    required this.onSurfaceVariant,
    this.title,
    this.titleSecondary,
    this.emptyActionLabel,
    this.onEmptyActionTap,
    this.onNoteEditTap,
    this.accentColor,
    this.photoUrl,
    required this.backFace,
    this.cardId,
    this.showCardIdOnBack = false,
    this.contactEmail,
    this.contactPhone,
    this.contactWebsite,
    this.contactLinkedin,
    this.visibleContactFields = const [],
    this.jobTitle,
  });

  static double get _radius => PersonInfoCard.compactCardRadius;

  static double get _photoRadius => PersonInfoCard.compactCardRadius * 0.5;

  static const double _photoSize = 64;

  final String? title;
  final String? titleSecondary;
  final List<({String label, String value})> entries;
  final String emptyMessage;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyActionTap;
  final VoidCallback? onNoteEditTap;
  final bool fillHeight;
  final bool backFace;
  final String? cardId;
  final bool showCardIdOnBack;
  final String? contactEmail;
  final String? contactPhone;
  final String? contactWebsite;
  final String? contactLinkedin;
  final List<String> visibleContactFields;
  final String? jobTitle;
  final Color? accentColor;
  final Color backgroundColor;
  final String? photoUrl;
  final bool showAppLogo;
  final bool showPremiumBadge;
  final double titleRightInset;
  final double bottomRightInset;
  final Color onSurface;
  final Color onSurfaceVariant;

  String? _valueForLabels(List<String> labels) {
    for (final entry in entries) {
      if (labels.contains(entry.label)) return entry.value;
    }
    return null;
  }

  String? get _email => _valueForLabels(['E-posta', 'Email']);

  String? get _phone => _valueForLabels(['Telefon', 'Phone']);

  String? get _aboutText => _valueForLabels(['Hakkımda', 'About']);

  String? get _skillsText => _valueForLabels(['Yetenekler', 'Skills']);

  bool _hasContactValue(String key) {
    switch (key) {
      case 'email':
        final fromEntry = _email;
        if (fromEntry != null && fromEntry.trim().isNotEmpty) return true;
        return contactEmail?.trim().isNotEmpty == true;
      case 'phone':
        final fromEntry = _phone;
        if (fromEntry != null && fromEntry.trim().isNotEmpty) return true;
        return contactPhone?.trim().isNotEmpty == true;
      case 'website':
        return contactWebsite?.trim().isNotEmpty == true;
      case 'linkedin':
        return contactLinkedin?.trim().isNotEmpty == true;
      default:
        return false;
    }
  }

  List<String> _limitedContactKeys() {
    return CardContactVisibility.limitedFrontContactKeys(
      preferredOrder: visibleContactFields,
      hasValue: _hasContactValue,
    );
  }

  bool _shouldShowContact(String key) {
    return _limitedContactKeys().contains(key);
  }

  String? _resolveContact(String? fromEntry, String? direct, String key) {
    if (!_shouldShowContact(key)) return null;
    if (fromEntry != null && fromEntry.trim().isNotEmpty) {
      return fromEntry.trim();
    }
    final value = direct?.trim();
    if (value != null && value.isNotEmpty) return value;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (backFace) {
      return _buildCardShell(
        context,
        child: _buildBackAboutContent(context),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final hasTitle = title != null && title!.trim().isNotEmpty;
    final resolvedJobTitle = jobTitle?.trim().isNotEmpty == true
        ? jobTitle!.trim()
        : _valueForLabels(['Pozisyon', 'Ünvan', 'Title']);
    final company = titleSecondary?.trim().isNotEmpty == true
        ? titleSecondary!.trim()
        : _valueForLabels(['Şirket', 'Company']);
    final email = _resolveContact(_email, contactEmail, 'email');
    final phone = _resolveContact(_phone, contactPhone, 'phone');
    final website = _resolveContact(null, contactWebsite, 'website');
    final linkedin = _resolveContact(null, contactLinkedin, 'linkedin');
    final hasContent = hasTitle ||
        resolvedJobTitle != null ||
        company != null ||
        email != null ||
        phone != null ||
        website != null ||
        linkedin != null;

    return _buildCardShell(
      context,
      child: !hasContent
          ? _buildEmptyState(context)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopSection(
                  textTheme,
                  hasTitle: hasTitle,
                  jobTitle: resolvedJobTitle,
                  company: company,
                ),
                if (fillHeight) const Spacer(),
                if (email != null ||
                    phone != null ||
                    website != null ||
                    linkedin != null)
                  Padding(
                    padding: EdgeInsets.only(
                      right: bottomRightInset > 0 ? bottomRightInset * 0.65 : 0,
                    ),
                    child: _buildContactFooter(
                      context,
                      textTheme,
                      email: email,
                      phone: phone,
                      website: website,
                      linkedin: linkedin,
                    ),
                  ),
                if (_noteEntry(context) != null && fillHeight) ...[
                  const SizedBox(height: 8),
                  Expanded(child: _buildNote(context, textTheme)),
                ],
              ],
            ),
    );
  }

  Widget _buildCardShell(BuildContext context, {required Widget child}) {
    final isSurfaceDark = backgroundColor.computeLuminance() < 0.35;
    final shadowOpacity = isSurfaceDark ? 0.52 : 0.24;
    const depth = 12.0;
    const blurMain = 30.0;
    final borderColorSubtle = onSurfaceVariant.withValues(alpha: 0.28);
    final innerRadius = _radius - 1;

    return Container(
      width: double.infinity,
      height: fillHeight ? double.infinity : null,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: borderColorSubtle, width: 1),
        boxShadow: PersonInfoCard.compactCardShadows(
          isSurfaceDark: isSurfaceDark,
          shadowOpacity: shadowOpacity,
          depth: depth,
          blurMain: blurMain,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(innerRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PersonInfoCard.compactCardTopHighlight(isSurfaceDark),
            if (showAppLogo)
              Positioned.fill(
                child: CardWatermark(
                  surfaceColor: backgroundColor,
                  variant: CardWatermarkVariant.cardCompact,
                ),
              ),
            if (showPremiumBadge)
              const Positioned(
                top: 8,
                left: 10,
                child: PremiumOwnerBadge(size: 20),
              ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  14,
                  14,
                  14 + titleRightInset,
                  14 + (bottomRightInset * 0.35),
                ),
                child: child,
              ),
            ),
            if (showCardIdOnBack)
              Positioned(
                top: 10,
                right: 12 + titleRightInset,
                child: CardBackIdBadge(
                  cardId: cardId,
                  onSurface: onSurface,
                  onSurfaceVariant: onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackAboutContent(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final about = _aboutText?.trim();
    final hasAbout = about != null && about.isNotEmpty;
    final skills = _skillsText?.trim();
    final hasSkills = skills != null && skills.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.hakkmda,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: onSurface,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          flex: hasSkills ? 3 : 1,
          child: Text(
            hasAbout ? about! : 'Hakkımda bilginizi ekleyebilirsiniz.',
            style: textTheme.bodySmall?.copyWith(
              color: hasAbout ? onSurface : onSurfaceVariant,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            maxLines: hasSkills ? 6 : 14,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasSkills) ...[
          const SizedBox(height: 14),
          Text(
            context.l10n.yetenekler,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: onSurface,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: Text(
              skills!,
              style: textTheme.bodySmall?.copyWith(
                color: onSurface,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  ({String label, String value})? _noteEntry(BuildContext context) {
    for (final entry in entries) {
      if (_isNoteLabel(entry.label) || entry.label == context.l10n.notlar) {
        return entry;
      }
    }
    return null;
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    if (emptyActionLabel != null && onEmptyActionTap != null) {
      return Center(
        child: CustomButton.tonal(
          label: emptyActionLabel!,
          icon: Icons.add_rounded,
          onPressed: onEmptyActionTap,
          fullWidth: false,
          visualDensity: VisualDensity.compact,
        ),
      );
    }
    return Center(
      child: Text(
        emptyMessage,
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(color: onSurfaceVariant),
      ),
    );
  }

  Widget _buildTopSection(
    TextTheme textTheme, {
    required bool hasTitle,
    String? jobTitle,
    String? company,
  }) {
    final hasText = hasTitle || company != null || jobTitle != null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasText)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle || company != null)
                  _buildNameCompanyLine(textTheme,
                      hasTitle: hasTitle, company: company),
                if (jobTitle != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    jobTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      color: Color.alphaBlend(
                        onSurface.withValues(alpha: 0.88),
                        backgroundColor,
                      ),
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (hasText) const SizedBox(width: 12),
        _buildPhotoSlot(),
      ],
    );
  }

  Widget _buildNameCompanyLine(
    TextTheme textTheme, {
    required bool hasTitle,
    String? company,
  }) {
    final nameStyle = textTheme.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: onSurface,
      letterSpacing: -0.2,
      height: 1.15,
    );
    final companyStyle = textTheme.labelSmall?.copyWith(
      fontSize: 12,
      color: onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.65,
      height: 1.25,
    );
    final bulletStyle = nameStyle?.copyWith(
      fontWeight: FontWeight.w500,
      color: onSurfaceVariant.withValues(alpha: 0.85),
    );

    final spans = <InlineSpan>[];
    if (hasTitle) {
      spans.add(TextSpan(text: title!, style: nameStyle));
    }
    if (company != null) {
      if (spans.isNotEmpty) {
        spans.add(TextSpan(text: ' • ', style: bulletStyle));
      }
      spans.add(TextSpan(text: company.toUpperCase(), style: companyStyle));
    }

    return Text.rich(
      TextSpan(children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPhotoSlot() {
    final url = photoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_photoRadius),
        child: ProfileAvatar(
          photoUrl: photoUrl,
          displayName: title,
          size: _photoSize,
        ),
      );
    }

    return Container(
      width: _photoSize,
      height: _photoSize,
      decoration: BoxDecoration(
        color: onSurfaceVariant.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(_photoRadius),
        border: Border.all(
          color: onSurfaceVariant.withValues(alpha: 0.22),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.badge_outlined,
        size: 30,
        color: onSurfaceVariant.withValues(alpha: 0.85),
      ),
    );
  }

  Widget _buildContactFooter(
    BuildContext context,
    TextTheme textTheme, {
    String? email,
    String? phone,
    String? website,
    String? linkedin,
  }) {
    final lines = <Widget>[];
    void addLine(Widget line) {
      if (lines.isNotEmpty) lines.add(const SizedBox(height: 5));
      lines.add(line);
    }

    for (final key in _limitedContactKeys()) {
      switch (key) {
        case 'email':
          if (email == null || email.trim().isEmpty) continue;
          final value = email.trim();
          addLine(
            _buildContactLine(
              textTheme,
              icon: Icons.mail_outline_rounded,
              value: value,
              onTap: () => ContactLauncher.launchEmail(context, value),
            ),
          );
        case 'phone':
          if (phone == null || phone.trim().isEmpty) continue;
          final value = phone.trim();
          addLine(
            _buildContactLine(
              textTheme,
              icon: Icons.phone_outlined,
              value: value,
              onTap: () => ContactLauncher.launchPhone(context, value),
            ),
          );
        case 'linkedin':
          if (linkedin == null || linkedin.trim().isEmpty) continue;
          final value = linkedin.trim();
          addLine(
            _buildContactLine(
              textTheme,
              icon: Icons.link_rounded,
              value: value,
              onTap: () => ContactLauncher.launchWebUrl(context, value),
            ),
          );
        case 'website':
          if (website == null || website.trim().isEmpty) continue;
          final value = website.trim();
          addLine(
            _buildContactLine(
              textTheme,
              icon: Icons.language_rounded,
              value: value,
              onTap: () => ContactLauncher.launchWebUrl(context, value),
            ),
          );
      }
    }
    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: lines,
    );
  }

  static const double _contactIconSize = 12;
  static const double _contactIconCircle = 20;
  static const double _contactIconSlot = 22;

  Widget _buildContactLine(
    TextTheme textTheme, {
    required IconData icon,
    required String value,
    VoidCallback? onTap,
  }) {
    final iconColor = accentColor ?? onSurfaceVariant;

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _contactIconSlot,
          child: Center(
            child: Container(
              width: _contactIconCircle,
              height: _contactIconCircle,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.14),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.28),
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: _contactIconSize,
                color: iconColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: onSurface,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ),
      ],
    );

    if (onTap == null) {
      return SizedBox(height: _contactIconCircle, child: row);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: _contactIconCircle,
          child: row,
        ),
      ),
    );
  }

  Widget _buildNote(BuildContext context, TextTheme textTheme) {
    final note = _noteEntry(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                note.label,
                style: textTheme.labelSmall?.copyWith(
                  color: onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onNoteEditTap != null)
              TextButton(
                onPressed: onNoteEditTap,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 28),
                ),
                child: Text(
                  context.l10n.dzenle,
                  style: textTheme.labelSmall?.copyWith(
                    color: onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: Text(
            note.value,
            style: textTheme.bodySmall?.copyWith(
              color: onSurface,
              height: 1.3,
            ),
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
