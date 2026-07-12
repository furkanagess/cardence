import 'package:flutter/material.dart';
import '../../../core/l10n/app_l10n.dart';
import '../../../core/l10n/l10n_extensions.dart';

import '../molecules/card_effect_overlay.dart';
import '../molecules/card_preview_action_strip.dart';
import '../../domain/card_visual_effect.dart';
import 'person_info_card.dart';

/// Dikdörtgen (kartvizit oranında) kişi kartı önizlemesi.
/// Alt sağda detay ve iletişim kısayolları; çevrilebilir değil.
class FlippablePersonCard extends StatelessWidget {
  const FlippablePersonCard({
    super.key,
    this.title,
    this.titleSecondary,
    this.frontEntries = const [],
    this.backEntries = const [],
    this.emptyMessage,
    this.backEmptyMessage,
    this.onBackEmptyActionTap,
    this.backEmptyActionLabel,
    this.onBackEditTap,
    this.accentColor,
    this.backgroundColor,
    this.photoUrl,
    this.cardId,
    this.onTap,
    this.onDetailTap,
    this.onDoubleTap,
    this.showAppLogo = true,
    this.flipOnTouch = false,
    this.contactEmail,
    this.contactPhone,
    this.contactWebsite,
    this.contactLinkedin,
    this.visibleContactFields = const [],
    this.jobTitle,
    this.contactFieldsTappable = true,
    this.cardEffect = CardVisualEffect.none,
    this.showActionStrip = true,
    this.heroTag,
  });

  final String? title;
  final String? titleSecondary;

  /// Ön yüzde gösterilecek alanlar (örn. şirket, ünvan, e-posta).
  final List<({String label, String value})> frontEntries;

  /// Eski flip arka yüzü; artık önizlemede kullanılmaz.
  final List<({String label, String value})> backEntries;
  final String? emptyMessage;
  final String? backEmptyMessage;
  final VoidCallback? onBackEmptyActionTap;
  final String? backEmptyActionLabel;
  final VoidCallback? onBackEditTap;

  /// Kart vurgu rengi (ikonlar vb.). null ise tema primary.
  final Color? accentColor;

  /// Kart arka plan rengi. null ise tema surface.
  final Color? backgroundColor;
  final String? photoUrl;
  final String? cardId;

  /// @deprecated Kart gövdesine dokunma kaldırıldı; [onDetailTap] kullanın.
  final VoidCallback? onTap;

  /// Detay ekranına gitme.
  final VoidCallback? onDetailTap;
  final VoidCallback? onDoubleTap;

  /// false: Cardence köşe logosu gizlenir (elle girilen kartlar).
  final bool showAppLogo;

  /// Artık kullanılmaz; geriye dönük uyumluluk için tutulur.
  final bool flipOnTouch;

  /// Alt iletişim (e-posta / telefon, ikonlu liste).
  final String? contactEmail;
  final String? contactPhone;
  final String? contactWebsite;
  final String? contactLinkedin;
  final List<String> visibleContactFields;
  final String? jobTitle;
  final bool contactFieldsTappable;
  final CardVisualEffect cardEffect;

  /// true: alt sağda detay + iletişim ikonları; kart içi iletişim satırları gizlenir.
  final bool showActionStrip;

  /// Detay geçişinde kart yüzünün Hero animasyonu için etiket.
  final String? heroTag;

  /// Hero etiketi kapsamları — IndexedStack sekmeleri arasında çakışmayı önler.
  static const String heroScopeWallet = 'wallet';
  static const String heroScopeProfile = 'profile';

  /// Kayıtlı / profil kartı detay geçişi için standart Hero etiketi.
  static String? heroTagForCardId(
    String? cardId, {
    String scope = heroScopeWallet,
  }) {
    final trimmed = cardId?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return 'saved-card-$scope-$trimmed';
  }

  /// Kartvizit oranı: genişlik / yükseklik (ISO 7810 ID-1 ~ 85.6×53.98 mm).
  static const double cardAspectRatio = 1.586;

  /// Shimmer / carousel için tipik yükseklik (~362px genişlikte).
  static const double fixedHeight = 228;

  static const int maxVisibleEntriesPerSide = 3;

  VoidCallback? get _resolvedDetailTap => onDetailTap ?? onTap;

  bool get _shouldShowActionStrip {
    if (!showActionStrip) return false;
    return _resolvedDetailTap != null ||
        contactEmail?.trim().isNotEmpty == true ||
        contactPhone?.trim().isNotEmpty == true ||
        contactLinkedin?.trim().isNotEmpty == true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardSurface = backgroundColor ?? colorScheme.surface;
    final cardFace = _wrapWithEffect(_buildFront(context));
    final heroChild = Material(
      color: Colors.transparent,
      child: cardFace,
    );

    return AspectRatio(
      aspectRatio: FlippablePersonCard.cardAspectRatio,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
                child: heroTag == null
                    ? heroChild
                    : Hero(
                        tag: heroTag!,
                        child: heroChild,
                      ),
              ),
            ),
            if (_shouldShowActionStrip)
              Positioned(
                left: 2,
                right: 2,
                bottom: 24,
                child: CardPreviewActionStrip(
                  cardSurfaceColor: cardSurface,
                  accentColor: accentColor,
                  onDetailTap: _resolvedDetailTap,
                  email: contactEmail,
                  phone: contactPhone,
                  linkedin: contactLinkedin,
                  contactFieldsTappable: contactFieldsTappable,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _wrapWithEffect(Widget card) {
    return CardEffectOverlay(
      effect: cardEffect,
      accentColor: accentColor,
      borderRadius: BorderRadius.circular(PersonInfoCard.compactCardRadius),
      child: card,
    );
  }

  Widget _buildFront(BuildContext context) {
    final defaultEmpty = AppL10n.noInfoYet(context.l10n);
    final resolvedEmpty = emptyMessage ?? defaultEmpty;

    return PersonInfoCard(
      title: title,
      titleSecondary: titleSecondary,
      entries: frontEntries
          .take(FlippablePersonCard.maxVisibleEntriesPerSide)
          .toList(),
      emptyMessage: resolvedEmpty,
      compact: true,
      fillHeight: true,
      accentColor: accentColor,
      backgroundColor: backgroundColor,
      photoUrl: photoUrl,
      bottomInset:
          _shouldShowActionStrip ? CardPreviewActionStrip.chipSize + 10 : 0,
      hideContactFooter: _shouldShowActionStrip,
      showAppLogo: showAppLogo,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      contactWebsite: contactWebsite,
      contactLinkedin: contactLinkedin,
      visibleContactFields:
          _shouldShowActionStrip ? const [] : visibleContactFields,
      jobTitle: jobTitle,
      contactFieldsTappable: contactFieldsTappable,
    );
  }
}
