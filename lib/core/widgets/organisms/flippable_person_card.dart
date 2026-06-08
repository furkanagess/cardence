import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

import '../atoms/custom_button.dart';
import 'person_info_card.dart';

/// Dikdörtgen (kartvizit oranında), çevrilebilir kişi kartı.
/// [flip_card] paketi ile; ön yüz [frontEntries], arka yüz [backEntries]. Sağ üstte flip ikonu.
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
    this.onTap,
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
  final VoidCallback? onTap;

  /// Kartvizit oranı: genişlik / yükseklik (ISO 7810 ID-1 ~ 85.6×53.98 mm).
  static const double cardAspectRatio = 1.586;
  static const double fixedHeight = 232;
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

    return SizedBox(
      height: FlippablePersonCard.fixedHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onTap,
              child: FlipCard(
                key: _cardKey,
                side: CardSide.FRONT,
                direction: FlipDirection.HORIZONTAL,
                speed: 400,
                flipOnTouch: false,
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
          if (!_isFlipping)
            Positioned(
              top: _flipButtonTop,
              right: _flipButtonRight,
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
    );
  }

  /// Klasik kartvizit köşe yuvarlaklığı (küçük radius).
  static const double _cardRadius = 12;

  /// PersonInfoCard (compact) başlık satırı: paddingTitleTop 14 + satır yüksekliği ~20 → merkez ~24.
  /// Flip butonu (padding 8 + icon 28 + padding 8) merkezi top + 22; hiza için top = 24 - 22 = 2.
  static const double _flipButtonTop = 2;
  static const double _flipButtonRight = 8;
  static const double _flipIconSize = 28;
  static const double _flipIconPadding = 8;

  Widget _buildFront(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = widget.backgroundColor ?? colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _buildCard3DShadow(surface),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: PersonInfoCard(
          title: widget.title,
          titleSecondary: widget.titleSecondary,
          entries: widget.frontEntries
              .take(FlippablePersonCard.maxVisibleEntriesPerSide)
              .toList(),
          emptyMessage: widget.emptyMessage,
          compact: true,
          accentColor: widget.accentColor,
          backgroundColor: widget.backgroundColor,
        ),
      ),
    );
  }

  /// 3D kart hissi: ön/arka yüz için çok katmanlı gölge + üst kenar vurgusu.
  static List<BoxShadow> _buildCard3DShadow(Color surface) {
    final isDark = surface.computeLuminance() < 0.35;
    final opacity = isDark ? 0.5 : 0.24;
    final highlight = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.white.withOpacity(0.5);
    return [
      BoxShadow(
        color: highlight,
        blurRadius: 4,
        offset: const Offset(-1, -2),
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(opacity * 0.4),
        blurRadius: 36,
        offset: const Offset(0, 4),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(opacity),
        blurRadius: 28,
        offset: const Offset(0, 14),
        spreadRadius: -4,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(opacity * 0.65),
        blurRadius: 18,
        offset: const Offset(0, 6),
      ),
    ];
  }

  Widget _buildBack(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = widget.backgroundColor ?? colorScheme.surface;
    final hasBackContent = widget.backEntries.isNotEmpty;
    final showCenteredAddNote = !hasBackContent &&
        widget.onBackEmptyActionTap != null;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _buildCard3DShadow(surface),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: showCenteredAddNote
            ? Center(
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
                fillHeight: true,
                accentColor: widget.accentColor,
                backgroundColor: widget.backgroundColor,
              ),
      ),
    );
  }
}
