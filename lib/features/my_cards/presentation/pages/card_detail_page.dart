import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../card_customize_colors.dart';
import '../widgets/collapsible_card_preview_panel.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import 'my_card_edit_page.dart';
import '../../../saved_cards/domain/entities/card_share_payload.dart';

/// Tek bir kartın detay ekranı; önizleme, kartı özelleştir (bottom sheet) ve paylaşım.
class CardDetailPage extends StatefulWidget {
  const CardDetailPage({
    super.key,
    required this.draft,
    required this.persistOnboardingCard,
    this.onDraftUpdated,
  });

  final OnboardingCardDraft draft;
  final PersistOnboardingCard persistOnboardingCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  late OnboardingCardDraft _draft;
  String? get _selectedBackground => _draft.backgroundColor;
  String? get _selectedTextColor => _draft.accentColor;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  static Color? _parseColor(String hex) {
    if (hex.length == 7 && hex.startsWith('#')) {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    }
    return null;
  }

  static String _colorToHex(Color c) {
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  Color? _backgroundColor() =>
      _selectedBackground != null ? _parseColor(_selectedBackground!) : null;

  bool get _hasLastUsed =>
      _draft.lastUsedPaletteBackgroundColor != null &&
      _draft.lastUsedPaletteBackgroundColor!.length == 7 &&
      _draft.lastUsedPaletteBackgroundColor!.startsWith('#') &&
      !cardBackgroundColorOptions.contains(_draft.lastUsedPaletteBackgroundColor);

  Future<void> _persistDraft(OnboardingCardDraft updated) async {
    final synced = await widget.persistOnboardingCard(updated);
    if (!mounted) return;
    setState(() => _draft = synced);
    widget.onDraftUpdated?.call(synced);
  }

  Future<void> _setDefaultBackground() async {
    final updated = _draft.copyWith(clearBackgroundColor: true);
    await _persistDraft(updated);
  }

  Future<void> _setBackgroundColor(String hex) async {
    await _persistDraft(_draft.copyWith(backgroundColor: hex));
  }

  Future<void> _setBackgroundColorFromPalette(String hex) async {
    await _persistDraft(
      _draft.copyWith(
        backgroundColor: hex,
        lastUsedPaletteBackgroundColor: hex,
      ),
    );
  }

  Future<void> _setDefaultTextColor() async {
    await _persistDraft(_draft.copyWith(clearAccentColor: true));
  }

  Future<void> _setTextColor(String hex) async {
    await _persistDraft(_draft.copyWith(accentColor: hex));
  }

  Future<void> _openCustomTextColorPicker() async {
    final current = _selectedTextColor != null
        ? _parseColor(_selectedTextColor!)
        : null;
    final bg = _backgroundColor();
    Color pickerColor = current ??
        (bg != null
            ? (bg.computeLuminance() > 0.5
                ? const Color(0xFF1C2430)
                : const Color(0xFFF5F5F5))
            : AppColors.textPrimary);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Özel metin rengi'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          CustomButton(
            label: 'Uygula',
            onPressed: () {
              Navigator.of(context).pop();
              _setTextColor(_colorToHex(pickerColor));
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  void _showCustomizeBottomSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _CustomizeCardSheetContent(
        initialBackgroundSelection: _selectedBackground,
        backgroundColorOptions: cardBackgroundColorOptions,
        hasLastUsedBackground: _hasLastUsed,
        lastUsedBackgroundHex: _draft.lastUsedPaletteBackgroundColor,
        initialTextSelection: _selectedTextColor,
        textColorOptions: cardTextColorOptions,
        parseColor: _parseColor,
        onSelectDefaultBackground: _setDefaultBackground,
        onSelectBackgroundColor: _setBackgroundColor,
        onOpenBackgroundPalette: () {
          Navigator.of(sheetContext).pop();
          _openCustomBackgroundColorPicker();
        },
        onSelectDefaultTextColor: _setDefaultTextColor,
        onSelectTextColor: _setTextColor,
        onOpenTextPalette: () {
          Navigator.of(sheetContext).pop();
          _openCustomTextColorPicker();
        },
      ),
    );
  }

  Future<void> _openCustomBackgroundColorPicker() async {
    final currentBg = _backgroundColor();
    final lastUsed = _draft.lastUsedPaletteBackgroundColor != null
        ? _parseColor(_draft.lastUsedPaletteBackgroundColor!)
        : null;
    Color pickerColor =
        currentBg ?? lastUsed ?? const Color(0xFFF5F5F5);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Özel kart rengi'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (c) => pickerColor = c,
            enableAlpha: false,
            hexInputBar: true,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          CustomButton(
            label: 'Uygula',
            onPressed: () {
              Navigator.of(context).pop();
              _setBackgroundColorFromPalette(_colorToHex(pickerColor));
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Future<void> _showShareQrDialog() async {
    String cardId = _draft.cardId ?? '';
    if (cardId.isEmpty) {
      const uuid = Uuid();
      cardId = uuid.v4();
      await _persistDraft(_draft.copyWith(cardId: cardId));
      cardId = _draft.cardId ?? cardId;
    }
    final payload = CardSharePayload(
      id: cardId,
      n: _draft.displayName?.trim().isEmpty ?? true ? null : _draft.displayName,
      e: _draft.email?.trim().isEmpty ?? true ? null : _draft.email,
      p: _draft.phone?.trim().isEmpty ?? true ? null : _draft.phone,
      c: _draft.company?.trim().isEmpty ?? true ? null : _draft.company,
      t: _draft.title?.trim().isEmpty ?? true ? null : _draft.title,
      w: _draft.website?.trim().isEmpty ?? true ? null : _draft.website,
      l: _draft.linkedin?.trim().isEmpty ?? true ? null : _draft.linkedin,
      s: _draft.skills?.trim().isEmpty ?? true ? null : _draft.skills,
      o: _draft.school?.trim().isEmpty ?? true ? null : _draft.school,
      h: _draft.about?.trim().isEmpty ?? true ? null : _draft.about,
    );
    final jsonStr = jsonEncode(payload.toJson());
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QR ile paylaş'),
        content: SizedBox(
          width: 280,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Diğer kişi bu QR\'ı Cardence ile okutarak kartınızı kaydedebilir.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: jsonStr,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: AppColors.surfaceLight,
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  'Kart ID: $cardId',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CardenceScaffold(
      backgroundColor: colorScheme.surface,
      appBar: CardenceAppBar(
        title: _draft.listTitle,
        actions: [
          CardenceAppBar.iconAction(
            icon: Icons.edit_outlined,
            tooltip: 'Bilgileri düzenle',
            onPressed: () async {
              final updated = await Navigator.of(context).push<OnboardingCardDraft>(
                MaterialPageRoute(
                  builder: (context) => MyCardEditPage(
                    initialDraft: _draft,
                    persistOnboardingCard: widget.persistOnboardingCard,
                    onDraftUpdated: widget.onDraftUpdated,
                  ),
                ),
              );
              if (!mounted || updated == null) return;
              setState(() => _draft = updated);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CollapsibleCardPreviewPanel(
            draft: _draft,
            emptyMessage: 'Kart bilgisi yok — düzenle ile ekleyin',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                _DetailSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        title: 'Görünüm',
                        subtitle: 'Arka plan, metin rengi ve kart stili.',
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'Kartı özelleştir',
                        icon: Icons.palette_outlined,
                        onPressed: _showCustomizeBottomSheet,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _DetailSection(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        title: 'Kartınızı paylaşın',
                        subtitle:
                            'Başka biri Cardence ile QR\'ı okutarak kartınızı kaydedebilir.',
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: 'QR ile paylaş',
                        icon: Icons.qr_code_2_rounded,
                        onPressed: _showShareQrDialog,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartı özelleştir bottom sheet: renge tıklanınca hemen uygulanır ve kaydedilir.
class _CustomizeCardSheetContent extends StatefulWidget {
  const _CustomizeCardSheetContent({
    required this.initialBackgroundSelection,
    required this.backgroundColorOptions,
    required this.hasLastUsedBackground,
    this.lastUsedBackgroundHex,
    required this.initialTextSelection,
    required this.textColorOptions,
    required this.parseColor,
    required this.onSelectDefaultBackground,
    required this.onSelectBackgroundColor,
    required this.onOpenBackgroundPalette,
    required this.onSelectDefaultTextColor,
    required this.onSelectTextColor,
    required this.onOpenTextPalette,
  });

  final String? initialBackgroundSelection;
  final List<String> backgroundColorOptions;
  final bool hasLastUsedBackground;
  final String? lastUsedBackgroundHex;
  final String? initialTextSelection;
  final List<String> textColorOptions;
  final Color? Function(String) parseColor;
  final Future<void> Function() onSelectDefaultBackground;
  final Future<void> Function(String hex) onSelectBackgroundColor;
  final VoidCallback onOpenBackgroundPalette;
  final Future<void> Function() onSelectDefaultTextColor;
  final Future<void> Function(String hex) onSelectTextColor;
  final VoidCallback onOpenTextPalette;

  @override
  State<_CustomizeCardSheetContent> createState() =>
      _CustomizeCardSheetContentState();
}

class _CustomizeCardSheetContentState extends State<_CustomizeCardSheetContent> {
  late String? _pendingBackground;
  late String? _pendingText;

  @override
  void initState() {
    super.initState();
    _pendingBackground = widget.initialBackgroundSelection;
    _pendingText = widget.initialTextSelection;
  }

  Widget _chipBorder({required bool isSelected, required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : colorScheme.outline.withValues(alpha: 0.4),
          width: isSelected ? 3 : 1.5,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildDefaultBackgroundChip() {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _pendingBackground == null;
    return GestureDetector(
      onTap: () async {
        setState(() => _pendingBackground = null);
        await widget.onSelectDefaultBackground();
      },
      child: _chipBorder(
        isSelected: isSelected,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? Icons.check_rounded : Icons.palette_outlined,
            color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundColorChip(String hex) {
    final color = widget.parseColor(hex);
    if (color == null) return const SizedBox.shrink();
    final isSelected = _pendingBackground == hex;
    return GestureDetector(
      onTap: () async {
        setState(() => _pendingBackground = hex);
        await widget.onSelectBackgroundColor(hex);
      },
      child: _chipBorder(
        isSelected: isSelected,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: isSelected
              ? Icon(
                  Icons.check_rounded,
                  color: color.computeLuminance() > 0.5
                      ? AppColors.textPrimary
                      : AppColors.textOnPrimary,
                  size: 22,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildDefaultTextChip() {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _pendingText == null;
    return GestureDetector(
      onTap: () async {
        setState(() => _pendingText = null);
        await widget.onSelectDefaultTextColor();
      },
      child: _chipBorder(
        isSelected: isSelected,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSelected ? Icons.check_rounded : Icons.title_outlined,
            color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildTextColorChip(String hex) {
    final color = widget.parseColor(hex);
    if (color == null) return const SizedBox.shrink();
    final isSelected = _pendingText == hex;
    return GestureDetector(
      onTap: () async {
        setState(() => _pendingText = hex);
        await widget.onSelectTextColor(hex);
      },
      child: _chipBorder(
        isSelected: isSelected,
        child: DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              'A',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color.computeLuminance() > 0.5
                    ? AppColors.textPrimary
                    : AppColors.textOnPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaletteButton(VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kartı özelleştir',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Arka plan ve metin rengi seçimleri anında kaydedilir.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Kart rengi',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildDefaultBackgroundChip(),
                ...widget.backgroundColorOptions
                    .map(_buildBackgroundColorChip),
                if (widget.hasLastUsedBackground &&
                    widget.lastUsedBackgroundHex != null)
                  _buildBackgroundColorChip(widget.lastUsedBackgroundHex!),
                _buildPaletteButton(widget.onOpenBackgroundPalette),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Metin rengi',
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Otomatik: arka plana göre okunabilir renk.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildDefaultTextChip(),
                ...widget.textColorOptions.map(_buildTextColorChip),
                _buildPaletteButton(widget.onOpenTextPalette),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Tamam',
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
