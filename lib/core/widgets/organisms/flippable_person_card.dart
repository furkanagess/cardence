import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

import '../atoms/custom_button.dart';
import 'person_info_card.dart';

/// Dikdörtgen (kartvizit oranında), çevrilebilir kişi kartı.
/// [flip_card] paketi ile; ön yüz [frontEntries], arka yüz [backEntries]. Sağ altta flip ikonu.
class FlippablePersonCard extends StatefulWidget {
  const FlippablePersonCard({
    super.key,
    this.title,
    this.titleSecondary,
    this.frontEntries = const [],
    this.backEntries = const [],
    this.emptyMessage = 'Henüz bilgi yok',
    this.backEmptyMessage,
    this.onBackEmptyActionTap,
    this.backEmptyActionLabel,
    this.onBackEditTap,
    this.accentColor,
    this.backgroundColor,
    this.photoUrl,
    this.cardId,
    this.onTap,
    this.onDoubleTap,
    this.showAppLogo = true,
    this.showPremiumBadge = false,
    this.flipOnTouch = false,
    this.contactEmail,
    this.contactPhone,
    this.contactWebsite,
    this.contactLinkedin,
    this.visibleContactFields = const [],
    this.jobTitle,
  });

  final String? title;
  final String? titleSecondary;

  /// Ön yüzde gösterilecek alanlar (örn. şirket, ünvan, e-posta).
  final List<({String label, String value})> frontEntries;

  /// Arka yüzde gösterilecek alanlar (örn. iletişim, linkler).
  final List<({String label, String value})> backEntries;
  final String emptyMessage;
  final String? backEmptyMessage;
  final VoidCallback? onBackEmptyActionTap;
  final String? backEmptyActionLabel;
  final VoidCallback? onBackEditTap;

  /// Kart vurgu rengi (ikonlar, flip butonu). null ise tema primary.
  final Color? accentColor;

  /// Kart arka plan rengi. null ise tema surface.
  final Color? backgroundColor;
  final String? photoUrl;
  final String? cardId;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  /// false: Cardence köşe logosu gizlenir (elle girilen kartlar).
  final bool showAppLogo;

  /// true: premium kart sahibi rozeti gösterilir.
  final bool showPremiumBadge;

  /// true: karta dokunarak çevirme.
  final bool flipOnTouch;

  /// Alt iletişim (e-posta / telefon, ikonlu liste).
  final String? contactEmail;
  final String? contactPhone;
  final String? contactWebsite;
  final String? contactLinkedin;
  final List<String> visibleContactFields;
  final String? jobTitle;

  /// Kartvizit oranı: genişlik / yükseklik (ISO 7810 ID-1 ~ 85.6×53.98 mm).
  static const double cardAspectRatio = 1.586;

  /// Shimmer / carousel için tipik yükseklik (~362px genişlikte).
  static const double fixedHeight = 228;

  static const int maxVisibleEntriesPerSide = 3;

  @override
  State<FlippablePersonCard> createState() => _FlippablePersonCardState();
}

class _FlippablePersonCardState extends State<FlippablePersonCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  bool _isFlipping = false;

  /// Kart arka planına göre metin/ikon rengi (kart içeriği ile aynı).
  static Color _flipIconColor(Color cardSurface) {
    return cardSurface.computeLuminance() > 0.5
        ? const Color(0xFF1C1C1C)
        : const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardSurface = widget.backgroundColor ?? colorScheme.surface;
    final flipIconColor = widget.accentColor ?? _flipIconColor(cardSurface);

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
                child: GestureDetector(
                  onTap: widget.onTap,
                  onDoubleTap: widget.onDoubleTap,
                  child: FlipCard(
                    key: _cardKey,
                    side: CardSide.FRONT,
                    direction: FlipDirection.HORIZONTAL,
                    speed: 400,
                    flipOnTouch: widget.flipOnTouch,
                    onFlip: () {
                      setState(() => _isFlipping = true);
                    },
                    onFlipDone: (isFront) {
                      setState(() => _isFlipping = false);
                    },
                    front: _buildFront(context),
                    back: _buildBack(context),
                  ),
                ),
              ),
            ),
            if (!_isFlipping)
              Positioned(
                right: _flipButtonRight,
                bottom: _flipButtonBottom,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _cardKey.currentState?.toggleCard(),
                    child: Padding(
                      padding: const EdgeInsets.all(_flipIconPadding),
                      child: Icon(
                        Icons.replay_circle_filled_outlined,
                        color: flipIconColor,
                        size: _flipIconSize,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static const double _flipButtonBottom = 16;
  static const double _flipButtonRight = 6;
  static const double _flipIconSize = 26;
  static const double _flipIconPadding = 6;
  static const double _flipIconTouchSize = _flipIconPadding * 2 + _flipIconSize;

  bool get _isProfileBackFace {
    final entries = widget.backEntries;
    if (entries.isEmpty) return false;
    return entries.every(
      (e) => e.label == 'Hakkımda' || e.label == 'Yetenekler',
    );
  }

  Widget _buildFront(BuildContext context) {
    return PersonInfoCard(
      title: widget.title,
      titleSecondary: widget.titleSecondary,
      entries: widget.frontEntries
          .take(FlippablePersonCard.maxVisibleEntriesPerSide)
          .toList(),
      emptyMessage: widget.emptyMessage,
      compact: true,
      fillHeight: true,
      accentColor: widget.accentColor,
      backgroundColor: widget.backgroundColor,
      photoUrl: widget.photoUrl,
      bottomRightInset: _flipIconTouchSize,
      showAppLogo: widget.showAppLogo,
      showPremiumBadge: widget.showPremiumBadge,
      contactEmail: widget.contactEmail,
      contactPhone: widget.contactPhone,
      contactWebsite: widget.contactWebsite,
      contactLinkedin: widget.contactLinkedin,
      visibleContactFields: widget.visibleContactFields,
      jobTitle: widget.jobTitle,
    );
  }

  Widget _buildBack(BuildContext context) {
    final hasBackContent = widget.backEntries.isNotEmpty;
    final showCenteredAddNote =
        !hasBackContent && widget.onBackEmptyActionTap != null;

    return showCenteredAddNote
        ? _buildBackShell(
            context,
            Center(
              child: CustomButton.tonal(
                label: widget.backEmptyActionLabel ?? 'Not ekle',
                icon: Icons.add_rounded,
                onPressed: widget.onBackEmptyActionTap,
                fullWidth: false,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          )
        : PersonInfoCard(
            title: widget.title,
            titleSecondary: widget.titleSecondary,
            entries: widget.backEntries
                .take(FlippablePersonCard.maxVisibleEntriesPerSide)
                .toList(),
            emptyMessage: widget.backEmptyMessage ?? widget.emptyMessage,
            emptyActionLabel: widget.backEmptyActionLabel,
            onEmptyActionTap: widget.onBackEmptyActionTap,
            onNoteEditTap: widget.onBackEditTap,
            compact: true,
            compactBackFace: _isProfileBackFace,
            fillHeight: true,
            cardId: widget.cardId,
            showCardIdOnBack: true,
            accentColor: widget.accentColor,
            backgroundColor: widget.backgroundColor,
            bottomRightInset: _flipIconTouchSize,
            showAppLogo: widget.showAppLogo,
            showPremiumBadge: widget.showPremiumBadge,
          );
  }

  Widget _buildBackShell(BuildContext context, Widget child) {
    final surface =
        widget.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final isSurfaceDark = surface.computeLuminance() < 0.35;
    final shadowOpacity = isSurfaceDark ? 0.52 : 0.24;
    const depth = 12.0;
    const blurMain = 30.0;
    const radius = PersonInfoCard.compactCardRadius;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: (widget.accentColor ?? surface).withValues(alpha: 0.22),
        ),
        boxShadow: PersonInfoCard.compactCardShadows(
          isSurfaceDark: isSurfaceDark,
          shadowOpacity: shadowOpacity,
          depth: depth,
          blurMain: blurMain,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PersonInfoCard.compactCardTopHighlight(isSurfaceDark),
            child,
          ],
        ),
      ),
    );
  }
}
