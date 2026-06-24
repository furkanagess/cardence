import 'dart:convert';
import '../../../../core/l10n/l10n_extensions.dart';

import 'package:cardence/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
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
  late OnboardingCardDraft _savedDraft;
  bool _saving = false;
  bool _sharing = false;
  String? get _selectedBackground => _draft.backgroundColor;
  String? get _selectedTextColor => _draft.accentColor;

  bool get _hasUnsavedChanges => !_draft.contentEquals(_savedDraft);

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    _savedDraft = widget.draft;
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
      !cardBackgroundColorOptions
          .contains(_draft.lastUsedPaletteBackgroundColor);

  void _applyDraft(OnboardingCardDraft updated) {
    setState(() => _draft = updated);
  }

  Future<void> _save() async {
    if (_saving || !_hasUnsavedChanges) return;
    setState(() => _saving = true);
    var draftToSave = _draft;
    if (!CardIdGenerator.isValid(draftToSave.cardId)) {
      draftToSave = draftToSave.copyWith(cardId: CardIdGenerator.generateBusinessCandidate());
    }
    try {
      final synced = await widget.persistOnboardingCard(draftToSave);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _draft = synced;
        _savedDraft = synced;
      });
      widget.onDraftUpdated?.call(synced);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.kartKaydedildi),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.kartKaydedilemediLtfenTekrarDeneyin),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _confirmDiscardChanges() {
    return CardenceConfirmDialog.show(
      context,
      title: context.l10n.kaydedilmemiDeiiklikler,
      message:
          context.l10n.yaptnzDeiikliklerKaydedilmedikmakIstediinize,
      confirmLabel: context.l10n.k,
      cancelLabel: context.l10n.iptal,
      icon: Icons.warning_amber_rounded,
      confirmIsDestructive: true,
    ).then((value) => value == true);
  }

  void _setDefaultBackground() {
    _applyDraft(_draft.copyWith(clearBackgroundColor: true));
  }

  void _setBackgroundColor(String hex) {
    _applyDraft(_draft.copyWith(backgroundColor: hex));
  }

  void _setBackgroundColorFromPalette(String hex) {
    _applyDraft(
      _draft.copyWith(
        backgroundColor: hex,
        lastUsedPaletteBackgroundColor: hex,
      ),
    );
  }

  void _setDefaultTextColor() {
    _applyDraft(_draft.copyWith(clearAccentColor: true));
  }

  void _setTextColor(String hex) {
    _applyDraft(_draft.copyWith(accentColor: hex));
  }

  Future<void> _openCustomTextColorPicker() async {
    final current =
        _selectedTextColor != null ? _parseColor(_selectedTextColor!) : null;
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
        title: Text(context.l10n.zelMetinRengi),
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
            child: Text(context.l10n.iptal),
          ),
          CustomButton(
            label: context.l10n.uygula,
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
    Color pickerColor = currentBg ?? lastUsed ?? const Color(0xFFF5F5F5);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.zelKartRengi),
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
            child: Text(context.l10n.iptal),
          ),
          CustomButton(
            label: context.l10n.uygula,
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

  String? get _visibleCardId {
    final id = _draft.cardId?.trim();
    if (id == null || id.isEmpty || !CardIdGenerator.isValid(id)) return null;
    return id;
  }

  Future<void> _copyCardId(String cardId) async {
    await Clipboard.setData(ClipboardData(text: cardId));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.kartIdKopyaland),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _shareMessage(String cardId) {
    final name = _draft.listTitle;
    return 'Merhaba! Cardence kartımı seninle paylaşıyorum.\n\n'
        'Kart: $name\n'
        'Kart ID: $cardId\n\n'
        'Cardence uygulamasında Kayıtlı Kartlar bölümünden '
        '"Kart ID ile ekle" seçeneğine bu numarayı yazarak '
        'kartımı kaydedebilirsin.';
  }

  Future<OnboardingCardDraft> _ensureShareableDraft() async {
    var draftToSave = _draft;
    if (!CardIdGenerator.isValid(draftToSave.cardId)) {
      draftToSave = draftToSave.copyWith(cardId: CardIdGenerator.generateBusinessCandidate());
      _applyDraft(draftToSave);
    }
    if (_hasUnsavedChanges || draftToSave.cardId != _savedDraft.cardId) {
      final synced = await widget.persistOnboardingCard(draftToSave);
      if (!mounted) return synced;
      setState(() {
        _draft = synced;
        _savedDraft = synced;
      });
      widget.onDraftUpdated?.call(synced);
      return synced;
    }
    return draftToSave;
  }

  Future<void> _shareCard() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final synced = await _ensureShareableDraft();
      final cardId = synced.cardId?.trim();
      if (!mounted || cardId == null || !CardIdGenerator.isValid(cardId)) {
        throw AuthApiException('Kart ID oluşturulamadı. Lütfen tekrar deneyin.');
      }
      await Share.share(_shareMessage(cardId), subject: 'Cardence kartım');
    } on AuthApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _showShareQrDialog() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    String cardId;
    try {
      final synced = await _ensureShareableDraft();
      cardId = synced.cardId?.trim() ?? '';
      if (!CardIdGenerator.isValid(cardId)) {
        throw AuthApiException('Kart ID oluşturulamadı. Lütfen tekrar deneyin.');
      }
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() => _sharing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (!mounted) return;
    setState(() => _sharing = false);
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
      ph: _draft.photoUrl?.trim().isEmpty ?? true ? null : _draft.photoUrl,
    );
    final jsonStr = jsonEncode(payload.toJson());
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.qrIlePayla),
        content: SizedBox(
          width: 280,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.scanQrToSaveCard,
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
                  context.l10n.kartIdCardid,
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
            child: Text(context.l10n.kapat),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_hasUnsavedChanges) return;
        final shouldLeave = await _confirmDiscardChanges();
        if (!mounted || !shouldLeave) return;
        Navigator.of(context).pop();
      },
      child: CardenceScaffold(
      appBar: CardenceAppBar(
        variant: CardenceAppBarVariant.editor,
        title: _draft.listTitle,
        actions: [
          CardenceAppBar.textAction(
            label: context.l10n.kaydet,
            onPressed: _hasUnsavedChanges ? _save : null,
            loading: _saving,
          ),
          CardenceAppBar.iconAction(
            icon: Icons.edit_outlined,
            tooltip: context.l10n.bilgileriDzenle,
            onPressed: () async {
              final updated =
                  await Navigator.of(context).push<OnboardingCardDraft>(
                MaterialPageRoute(
                  builder: (context) => MyCardEditPage(
                    initialDraft: _draft,
                    persistOnboardingCard: widget.persistOnboardingCard,
                    onDraftUpdated: (synced) {
                      widget.onDraftUpdated?.call(synced);
                      if (!mounted) return;
                      setState(() {
                        _draft = synced;
                        _savedDraft = synced;
                      });
                    },
                  ),
                ),
              );
              if (!mounted || updated == null) return;
              setState(() {
                _draft = updated;
                _savedDraft = updated;
              });
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CollapsibleCardPreviewPanel(
            draft: _draft,
            emptyMessage: context.l10n.kartBilgisiYokDzenleIle,
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
                        title: context.l10n.grnm,
                        subtitle: context.l10n.arkaPlanMetinRengiVe,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: context.l10n.kartzelletir,
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
                        title: context.l10n.kartnzPaylan,
                        subtitle: context.l10n.shareCardIdSubtitle,
                      ),
                      const SizedBox(height: 12),
                      _CardIdTile(
                        cardId: _visibleCardId,
                        onCopy: _visibleCardId == null
                            ? null
                            : () => _copyCardId(_visibleCardId!),
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        label: context.l10n.kartPayla,
                        icon: Icons.share_outlined,
                        onPressed: _shareCard,
                        isLoading: _sharing,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomButton.tonal(
                        label: context.l10n.qrIlePayla,
                        icon: Icons.qr_code_2_rounded,
                        onPressed: _sharing ? null : _showShareQrDialog,
                        enabled: !_sharing,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}

/// Kartı özelleştir bottom sheet: renge tıklanınca önizlemeye yansır; kayıt Kaydet ile yapılır.
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
  final VoidCallback onSelectDefaultBackground;
  final void Function(String hex) onSelectBackgroundColor;
  final VoidCallback onOpenBackgroundPalette;
  final VoidCallback onSelectDefaultTextColor;
  final void Function(String hex) onSelectTextColor;
  final VoidCallback onOpenTextPalette;

  @override
  State<_CustomizeCardSheetContent> createState() =>
      _CustomizeCardSheetContentState();
}

class _CustomizeCardSheetContentState
    extends State<_CustomizeCardSheetContent> {
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
      onTap: () {
        setState(() => _pendingBackground = null);
        widget.onSelectDefaultBackground();
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
            color:
                isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
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
      onTap: () {
        setState(() => _pendingBackground = hex);
        widget.onSelectBackgroundColor(hex);
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
        widget.onSelectDefaultTextColor();
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
            color:
                isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
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
        widget.onSelectTextColor(hex);
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
          child:
              Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
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
              context.l10n.kartzelletir,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.arkaPlanVeMetinRengi,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.kartRengi2,
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
                ...widget.backgroundColorOptions.map(_buildBackgroundColorChip),
                if (widget.hasLastUsedBackground &&
                    widget.lastUsedBackgroundHex != null)
                  _buildBackgroundColorChip(widget.lastUsedBackgroundHex!),
                _buildPaletteButton(widget.onOpenBackgroundPalette),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.metinRengi2,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.otomatikArkaPlanaGreOkunabilir,
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
              label: context.l10n.tamam,
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

class _CardIdTile extends StatelessWidget {
  const _CardIdTile({
    required this.cardId,
    this.onCopy,
  });

  final String? cardId;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasId = cardId != null;

    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onCopy,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.kartId2,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasId ? cardId! : 'Paylaşınca oluşturulur',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: hasId ? 2 : 0,
                        fontFeatures: hasId
                            ? const [FontFeature.tabularFigures()]
                            : null,
                      ),
                    ),
                    if (!hasId) ...[
                      const SizedBox(height: 4),
                      Text(
                        context.l10n.kartPaylaDediinizdeBenzersizBir,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (hasId)
                IconButton(
                  tooltip: context.l10n.kopyala,
                  visualDensity: VisualDensity.compact,
                  onPressed: onCopy,
                  icon: Icon(
                    Icons.copy_all_rounded,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
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
