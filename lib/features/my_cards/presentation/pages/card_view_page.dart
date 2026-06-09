import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../card_customize_colors.dart';
import 'card_detail_page.dart';

const Map<String, String> _fieldLabels = {
  'displayName': 'Ad',
  'email': 'E-posta',
  'phone': 'Telefon',
  'company': 'Şirket',
  'title': 'Ünvan',
  'website': 'Web sitesi',
  'linkedin': 'LinkedIn',
  'skills': 'Yetenekler',
  'school': 'Okul',
  'about': 'Hakkımda',
};

class _FieldDragData {
  const _FieldDragData({required this.fieldKey, required this.fromFront});

  final String fieldKey;
  final bool fromFront;
}

/// Kart görünümü: önizleme, renk düzenlemesi, gösterilecek alanlar, yeni kart oluşturma.
class CardViewPage extends StatefulWidget {
  const CardViewPage({
    super.key,
    required this.getOnboardingDraftCards,
    required this.persistOnboardingCard,
    this.onDraftUpdated,
  });

  final GetOnboardingDraftCards getOnboardingDraftCards;
  final PersistOnboardingCard persistOnboardingCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  State<CardViewPage> createState() => _CardViewPageState();
}

class _CardViewPageState extends State<CardViewPage> {
  List<OnboardingCardDraft> _cards = [];
  int _selectedIndex = 0;
  bool _loading = true;
  static const double _carouselViewportFraction = 0.88;
  late final PageController _pageController = PageController(viewportFraction: _carouselViewportFraction);

  OnboardingCardDraft? get _draft =>
      _cards.isEmpty ? null : _cards[_selectedIndex.clamp(0, _cards.length - 1)];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    final list = await widget.getOnboardingDraftCards();
    if (!mounted) return;
    setState(() {
      _cards = list;
      if (_selectedIndex >= _cards.length) _selectedIndex = _cards.isEmpty ? 0 : _cards.length - 1;
      _loading = false;
    });
    if (_cards.length > 1 && _selectedIndex > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _selectedIndex.clamp(0, _cards.length - 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _saveDraft(OnboardingCardDraft updated) async {
    final synced = await widget.persistOnboardingCard(updated);
    if (!mounted) return;
    final idx = _cards.indexWhere((c) => c.cardId == synced.cardId);
    if (idx >= 0) {
      _cards = List.from(_cards)..[idx] = synced;
    } else {
      _cards = List.from(_cards)..add(synced);
    }
    setState(() {});
    widget.onDraftUpdated?.call(synced);
  }

  static String? _value(OnboardingCardDraft d, String key) {
    switch (key) {
      case 'displayName': return d.displayName;
      case 'email': return d.email;
      case 'phone': return d.phone;
      case 'company': return d.company;
      case 'title': return d.title;
      case 'website': return d.website;
      case 'linkedin': return d.linkedin;
      case 'skills': return d.skills;
      case 'school': return d.school;
      case 'about': return d.about;
      default: return null;
    }
  }

  static Color? _parseHex(String? hex) {
    if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  static String _colorToHex(Color c) {
    final r = (c.r * 255).round().clamp(0, 255);
    final g = (c.g * 255).round().clamp(0, 255);
    final b = (c.b * 255).round().clamp(0, 255);
    return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
  }

  bool _hasFieldValue(OnboardingCardDraft d, String key) {
    final value = _value(d, key);
    return value != null && value.trim().isNotEmpty;
  }

  bool _canAcceptDrop(OnboardingCardDraft d, String key, {required bool toFront}) {
    if (!_hasFieldValue(d, key)) return false;
    final list = toFront ? d.frontVisibleFields : d.backVisibleFields;
    final max = toFront ? AppConstants.maxFrontCardFields : AppConstants.maxBackCardFields;
    if (list.contains(key)) return true;
    return list.length < max;
  }

  List<String> _displayFieldKeys(OnboardingCardDraft draft, bool isFront) {
    final baseKeys = isFront ? OnboardingCardDraft.frontFieldKeys : OnboardingCardDraft.backFieldKeys;
    final keysWithValue = baseKeys.where((key) => _hasFieldValue(draft, key)).toList();
    if (keysWithValue.isEmpty) return const [];
    final selected = (isFront ? draft.frontVisibleFields : draft.backVisibleFields)
        .where(keysWithValue.contains)
        .toList();
    final remaining = keysWithValue.where((key) => !selected.contains(key)).toList();
    return [...selected, ...remaining];
  }

  Widget _buildFieldList({
    required bool isFront,
    required bool enableReorder,
    required OnboardingCardDraft draft,
    required ColorScheme colorScheme,
  }) {
    final orderedKeys = _displayFieldKeys(draft, isFront);

    if (orderedKeys.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Bu yüzde gösterilecek alan yok.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Column(
      children: [
        ...orderedKeys.map(
          (key) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildFieldTile(
              draft: draft,
              fieldKey: key,
              isFront: isFront,
              colorScheme: colorScheme,
              enableReorder: enableReorder,
            ),
          ),
        ),
        if (enableReorder) _buildListEndDropZone(draft: draft, isFront: isFront),
      ],
    );
  }

  Widget _buildFieldTile({
    required OnboardingCardDraft draft,
    required String fieldKey,
    required bool isFront,
    required ColorScheme colorScheme,
    required bool enableReorder,
  }) {
    final child = _buildFieldTileContent(
      draft: draft,
      fieldKey: fieldKey,
      isFront: isFront,
      colorScheme: colorScheme,
    );

    return DragTarget<_FieldDragData>(
      onWillAccept: (data) => _canAcceptDropOnTile(
        data: data,
        draft: draft,
        fieldKey: fieldKey,
        isFront: isFront,
        enableReorder: enableReorder,
      ),
      onAccept: (data) => _handleTileDrop(
        data: data,
        draft: draft,
        targetKey: fieldKey,
        isFront: isFront,
        enableReorder: enableReorder,
      ),
      builder: (context, candidateData, rejected) {
        final highlight = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: highlight ? AppColors.primary : Colors.transparent,
              width: highlight ? 1.5 : 0.0,
            ),
            color: highlight ? AppColors.primary.withValues(alpha: 0.05) : Colors.transparent,
          ),
          padding: const EdgeInsets.all(1),
          child: LongPressDraggable<_FieldDragData>(
            data: _FieldDragData(fieldKey: fieldKey, fromFront: isFront),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: _buildFieldTileContent(
                  draft: draft,
                  fieldKey: fieldKey,
                  isFront: isFront,
                  colorScheme: colorScheme,
                  ignorePointer: true,
                ),
              ),
            ),
            childWhenDragging: _buildFieldTileContent(
              draft: draft,
              fieldKey: fieldKey,
              isFront: isFront,
              colorScheme: colorScheme,
              ignorePointer: true,
              opacity: 0.4,
            ),
            child: child,
          ),
        );
      },
    );
  }

  bool _canAcceptDropOnTile({
    required _FieldDragData? data,
    required OnboardingCardDraft draft,
    required String fieldKey,
    required bool isFront,
    required bool enableReorder,
  }) {
    if (data == null) return false;
    if (data.fromFront == isFront) {
      if (!enableReorder) return false;
      if (data.fieldKey == fieldKey) return false;
      return _isReorderableKey(draft, data.fieldKey, isFront);
    }
    return _canAcceptDrop(draft, data.fieldKey, toFront: isFront);
  }

  void _handleTileDrop({
    required _FieldDragData data,
    required OnboardingCardDraft draft,
    required String targetKey,
    required bool isFront,
    required bool enableReorder,
  }) {
    if (data.fromFront == isFront) {
      if (!enableReorder) return;
      _handleSameSideDrop(
        draft: draft,
        isFront: isFront,
        draggedKey: data.fieldKey,
        beforeKey: targetKey,
      );
    } else {
      if (!_canAcceptDrop(draft, data.fieldKey, toFront: isFront)) return;
      unawaited(_moveFieldBetweenSides(draft, data.fieldKey, toFront: isFront));
    }
  }

  bool _isReorderableKey(OnboardingCardDraft draft, String key, bool isFront) {
    final selected = isFront ? draft.frontVisibleFields : draft.backVisibleFields;
    return selected.contains(key);
  }

  void _handleSameSideDrop({
    required OnboardingCardDraft draft,
    required bool isFront,
    required String draggedKey,
    required String? beforeKey,
  }) {
    final selected = isFront ? draft.frontVisibleFields : draft.backVisibleFields;
    if (!selected.contains(draggedKey)) return;
    final orderedKeys = _displayFieldKeys(draft, isFront);
    final targetIndex = beforeKey == null ? orderedKeys.length : orderedKeys.indexOf(beforeKey);
    final insertIndex = beforeKey == null
        ? selected.length
        : selected.contains(beforeKey)
            ? selected.indexOf(beforeKey)
            : (targetIndex < 0 ? selected.length : _countSelectedBeforeIndex(selected, orderedKeys, targetIndex));
    unawaited(_reorderSelectedField(
      draft: draft,
      isFront: isFront,
      fieldKey: draggedKey,
      insertIndex: insertIndex,
    ));
  }

  int _countSelectedBeforeIndex(List<String> selected, List<String> orderedKeys, int targetIndex) {
    if (targetIndex <= 0) return 0;
    var count = 0;
    for (var i = 0; i < targetIndex && i < orderedKeys.length; i++) {
      if (selected.contains(orderedKeys[i])) count++;
    }
    return count;
  }

  Future<void> _reorderSelectedField({
    required OnboardingCardDraft draft,
    required bool isFront,
    required String fieldKey,
    required int insertIndex,
  }) async {
    final list = List<String>.from(isFront ? draft.frontVisibleFields : draft.backVisibleFields);
    final currentIndex = list.indexOf(fieldKey);
    if (currentIndex == -1) return;
    var targetIndex = insertIndex.clamp(0, list.length);
    if (currentIndex < targetIndex) targetIndex -= 1;
    list.removeAt(currentIndex);
    list.insert(targetIndex, fieldKey);
    final updated = isFront ? draft.copyWith(frontVisibleFields: list) : draft.copyWith(backVisibleFields: list);
    await _saveDraft(updated);
  }

  Widget _buildListEndDropZone({
    required OnboardingCardDraft draft,
    required bool isFront,
  }) {
    return DragTarget<_FieldDragData>(
      onWillAccept: (data) =>
          data != null && data.fromFront == isFront && _isReorderableKey(draft, data.fieldKey, isFront),
      onAccept: (data) => _handleSameSideDrop(
        draft: draft,
        isFront: isFront,
        draggedKey: data.fieldKey,
        beforeKey: null,
      ),
      builder: (context, candidate, rejected) {
        final highlight = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: highlight ? AppColors.primary : Colors.transparent,
              width: highlight ? 1.5 : 0,
            ),
          ),
          child: Text(
            'Listenin sonuna bırak',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: highlight ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        );
      },
    );
  }

  Widget _buildFieldTileContent({
    required OnboardingCardDraft draft,
    required String fieldKey,
    required bool isFront,
    required ColorScheme colorScheme,
    bool ignorePointer = false,
    double opacity = 1,
  }) {
    final label = _fieldLabels[fieldKey] ?? fieldKey;
    final selectedList = isFront ? draft.frontVisibleFields : draft.backVisibleFields;
    final isSelected = selectedList.contains(fieldKey);
    final max = isFront ? AppConstants.maxFrontCardFields : AppConstants.maxBackCardFields;
    final canAdd = selectedList.length < max;
    final selectedIndex = selectedList.indexOf(fieldKey);
    final canMoveUp = selectedIndex > 0;
    final canMoveDown = selectedIndex != -1 && selectedIndex < selectedList.length - 1;
    final canSendOpposite = isSelected || _canAcceptDrop(draft, fieldKey, toFront: !isFront);

    Widget buildIconButton({
      required IconData icon,
      required VoidCallback? onPressed,
      String? tooltip,
    }) {
      return IconButton(
        icon: Icon(icon, size: 20),
        color: colorScheme.onSurfaceVariant,
        splashRadius: 18,
        tooltip: tooltip,
        onPressed: ignorePointer ? null : onPressed,
      );
    }

    final tile = Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: ignorePointer
            ? null
            : (v) {
                if (v == true && !canAdd) return;
                if (isFront) {
                  _toggleFrontField(draft, fieldKey);
                } else {
                  _toggleBackField(draft, fieldKey);
                }
              },
        title: Text(label),
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        dense: true,
        secondary: SizedBox(
          width: 132,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              buildIconButton(
                icon: Icons.align_vertical_top,
                tooltip: 'Yukarı hizala',
                onPressed: canMoveUp
                    ? () => isFront ? _moveFrontField(draft, fieldKey, -1) : _moveBackField(draft, fieldKey, -1)
                    : null,
              ),
              buildIconButton(
                icon: Icons.align_vertical_bottom,
                tooltip: 'Aşağı hizala',
                onPressed: canMoveDown
                    ? () => isFront ? _moveFrontField(draft, fieldKey, 1) : _moveBackField(draft, fieldKey, 1)
                    : null,
              ),
              buildIconButton(
                icon: isFront ? Icons.flip_to_back : Icons.flip_to_front,
                tooltip: isFront ? 'Arka yüze taşı' : 'Ön yüze taşı',
                onPressed: canSendOpposite ? () => _moveFieldBetweenSides(draft, fieldKey, toFront: !isFront) : null,
              ),
            ],
          ),
        ),
      ),
    );

    return Opacity(
      opacity: opacity,
      child: IgnorePointer(
        ignoring: ignorePointer,
        child: tile,
      ),
    );
  }

  Future<void> _setBackgroundColor(OnboardingCardDraft d, String? hex) async {
    final updated = hex == null ? d.copyWith(clearBackgroundColor: true) : d.copyWith(backgroundColor: hex);
    await _saveDraft(updated);
  }

  Future<void> _setBackgroundColorFromPalette(OnboardingCardDraft d, String hex) async {
    final updated = d.copyWith(backgroundColor: hex, lastUsedPaletteBackgroundColor: hex);
    await _saveDraft(updated);
  }

  Future<void> _setTextColor(OnboardingCardDraft d, String? hex) async {
    final updated = hex == null
        ? d.copyWith(clearAccentColor: true)
        : d.copyWith(accentColor: hex);
    await _saveDraft(updated);
  }

  Future<void> _openCustomTextColorPicker(OnboardingCardDraft d) async {
    final current = d.accentColor != null ? _parseHex(d.accentColor) : null;
    final bg = _parseHex(d.backgroundColor);
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
              final r = (pickerColor.r * 255).round().clamp(0, 255);
              final g = (pickerColor.g * 255).round().clamp(0, 255);
              final b = (pickerColor.b * 255).round().clamp(0, 255);
              final hex =
                  '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
              _setTextColor(d, hex);
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFrontField(OnboardingCardDraft d, String fieldKey) async {
    final list = List<String>.from(d.frontVisibleFields);
    if (list.contains(fieldKey)) {
      list.remove(fieldKey);
    } else if (list.length < AppConstants.maxFrontCardFields) {
      list.add(fieldKey);
    } else {
      return;
    }
    final updated = d.copyWith(frontVisibleFields: list);
    await _saveDraft(updated);
  }

  Future<void> _toggleBackField(OnboardingCardDraft d, String fieldKey) async {
    final list = List<String>.from(d.backVisibleFields);
    if (list.contains(fieldKey)) {
      list.remove(fieldKey);
    } else if (list.length < AppConstants.maxBackCardFields) {
      list.add(fieldKey);
    } else {
      return;
    }
    final updated = d.copyWith(backVisibleFields: list);
    await _saveDraft(updated);
  }

  Future<void> _moveFrontField(OnboardingCardDraft d, String fieldKey, int direction) async {
    final list = List<String>.from(d.frontVisibleFields);
    final index = list.indexOf(fieldKey);
    if (index == -1) return;
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= list.length) return;
    list.removeAt(index);
    list.insert(newIndex, fieldKey);
    final updated = d.copyWith(frontVisibleFields: list);
    await _saveDraft(updated);
  }

  Future<void> _moveBackField(OnboardingCardDraft d, String fieldKey, int direction) async {
    final list = List<String>.from(d.backVisibleFields);
    final index = list.indexOf(fieldKey);
    if (index == -1) return;
    final newIndex = index + direction;
    if (newIndex < 0 || newIndex >= list.length) return;
    list.removeAt(index);
    list.insert(newIndex, fieldKey);
    final updated = d.copyWith(backVisibleFields: list);
    await _saveDraft(updated);
  }

  Future<void> _moveFieldBetweenSides(OnboardingCardDraft d, String fieldKey, {required bool toFront}) async {
    final front = List<String>.from(d.frontVisibleFields);
    final back = List<String>.from(d.backVisibleFields);
    if (toFront) {
      if (front.length >= AppConstants.maxFrontCardFields) return;
      back.remove(fieldKey);
      if (!front.contains(fieldKey)) {
        front.add(fieldKey);
      }
    } else {
      if (back.length >= AppConstants.maxBackCardFields) return;
      front.remove(fieldKey);
      if (!back.contains(fieldKey)) {
        back.add(fieldKey);
      }
    }
    final updated = d.copyWith(frontVisibleFields: front, backVisibleFields: back);
    await _saveDraft(updated);
  }

  Future<void> _createNewCard() async {
    final current = _draft ?? const OnboardingCardDraft();
    final newId = CardIdGenerator.generate();
    final copy = current.copyWith(
      cardId: newId,
      cardName: 'Yeni kart',
      frontVisibleFields: current.shouldMigrateFrontFields
          ? List<String>.from(OnboardingCardDraft.defaultFrontVisibleFields)
          : List.from(current.frontVisibleFields),
      backVisibleFields: current.backVisibleFields.isEmpty
          ? List<String>.from(OnboardingCardDraft.backFieldKeys.take(3))
          : List.from(current.backVisibleFields),
    );
    final synced = await widget.persistOnboardingCard(copy);
    if (!mounted) return;
    await _loadCards();
    final idx = _cards.indexWhere((c) => c.cardId == synced.cardId);
    if (idx >= 0) setState(() => _selectedIndex = idx);
    widget.onDraftUpdated?.call(synced);
  }

  Future<void> _openColorPalette() async {
    final d = _draft;
    if (d == null) return;
    final currentBg = _parseHex(d.backgroundColor);
    final lastUsed = d.lastUsedPaletteBackgroundColor != null ? _parseHex(d.lastUsedPaletteBackgroundColor!) : null;
    Color pickerColor = currentBg ?? lastUsed ?? const Color(0xFFF5F5F5);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('İptal')),
          CustomButton(
            label: 'Uygula',
            onPressed: () {
              Navigator.of(ctx).pop();
              _setBackgroundColorFromPalette(d, _colorToHex(pickerColor));
            },
            fullWidth: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_loading) {
      return CardenceScaffold(
        appBar: const CardenceAppBar(title: 'Kart Görünümü'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cards.isEmpty) {
      return CardenceScaffold(
        appBar: const CardenceAppBar(title: 'Kart Görünümü'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card_off_rounded, size: 64, color: colorScheme.outline.withValues(alpha: 0.6)),
                const SizedBox(height: 16),
                Text(
                  'Henüz kart yok',
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Profil bilgilerinizi doldurup ilk kartınızı oluşturun veya aşağıdan yeni kart ekleyin.',
                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: 'Yeni kart oluştur',
                  icon: Icons.add_rounded,
                  onPressed: _createNewCard,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final d = _draft!;
    final hasLastUsed = d.lastUsedPaletteBackgroundColor != null &&
        d.lastUsedPaletteBackgroundColor!.length == 7 &&
        d.lastUsedPaletteBackgroundColor!.startsWith('#') &&
        !cardBackgroundColorOptions.contains(d.lastUsedPaletteBackgroundColor);
    const cardHorizontalPadding = 16.0;
    final isCarousel = _cards.length > 1;
    const dotRowHeight = 24.0;

    return CardenceScaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CardenceAppBar(title: 'Kart Görünümü'),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: FlippablePersonCard.cardAspectRatio,
              child: isCarousel
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: _cards.length,
                      onPageChanged: (index) => setState(() => _selectedIndex = index),
                      padEnds: false,
                      itemBuilder: (context, index) {
                        final draft = _cards[index];

                        return AnimatedBuilder(
                          animation: _pageController,
                          builder: (context, child) {
                            double t = 0;
                            if (_pageController.position.haveDimensions) {
                              final page = _pageController.page ?? _pageController.initialPage.toDouble();
                              t = (page - index).abs().clamp(0.0, 1.0);
                            }
                            const maxScaleDelta = 0.06;
                            const maxFadeDelta = 0.2;
                            final scale = 1.0 - (t * maxScaleDelta);
                            final opacity = 1.0 - (t * maxFadeDelta);

                            return Opacity(
                              opacity: opacity,
                              child: Transform.scale(
                                scale: scale,
                                child: child,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: cardHorizontalPadding),
                            child: MyCardPreviewHelpers.flippableCard(
                              draft: draft,
                              emptyMessage: 'Kart bilgisi yok',
                            ),
                          ),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: cardHorizontalPadding),
                      child: MyCardPreviewHelpers.flippableCard(
                        draft: d,
                        emptyMessage: 'Kart bilgisi yok',
                      ),
                    ),
            ),
            if (isCarousel)
              SizedBox(
                height: dotRowHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_cards.length, (i) {
                    final isActive = i == _selectedIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : colorScheme.outline.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            const SizedBox(height: 24),
            Text(
              isCarousel ? 'Seçili kart bilgileri' : 'Kart bilgileri',
              style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              isCarousel
                  ? 'Aşağıdaki ayarlar şu an seçili karta aittir.'
                  : 'Renk ve gösterilecek alanları düzenleyebilirsiniz.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              'Kart rengi',
              style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildColorChip(d, null),
                ...cardBackgroundColorOptions.map((hex) => _buildColorChip(d, hex)),
                if (hasLastUsed && d.lastUsedPaletteBackgroundColor != null)
                  _buildColorChip(d, d.lastUsedPaletteBackgroundColor!),
                _buildPaletteButton(),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Metin rengi',
              style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Otomatik: arka plana göre okunabilir renk.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTextColorChip(d, null),
                ...cardTextColorOptions.map((hex) => _buildTextColorChip(d, hex)),
                _buildTextPaletteButton(d),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Kartta gösterilecek bilgiler',
              style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Ön ve arka yüzde en fazla ${AppConstants.maxFrontCardFields} alan seçin.',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              'Ön yüz',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildFieldList(isFront: true, enableReorder: true, draft: d, colorScheme: colorScheme),
            const SizedBox(height: 16),
            Text(
              'Arka yüz',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildFieldList(isFront: false, enableReorder: false, draft: d, colorScheme: colorScheme),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => CardDetailPage(
                      draft: d,
                      persistOnboardingCard: widget.persistOnboardingCard,
                      onDraftUpdated: (updated) {
                        widget.onDraftUpdated?.call(updated);
                        _loadCards();
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.tune_rounded, size: 20),
              label: const Text('Tasarım ve QR paylaşımı'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.6)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: 'Yeni kart oluştur',
              icon: Icons.add_rounded,
              onPressed: _createNewCard,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorChip(OnboardingCardDraft d, String? hex) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDefault = hex == null;
    final isSelected = isDefault ? d.backgroundColor == null : d.backgroundColor == hex;
    final color = hex != null ? _parseHex(hex) : colorScheme.surface;

    return GestureDetector(
      onTap: () => _setBackgroundColor(d, hex),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : colorScheme.outline.withValues(alpha: 0.4),
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: isDefault
            ? Icon(isSelected ? Icons.check_rounded : Icons.palette_outlined, color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant, size: 22)
            : (isSelected && color != null && color.computeLuminance() > 0.5)
                ? Icon(Icons.check_rounded, color: AppColors.textPrimary, size: 22)
                : null,
      ),
    );
  }

  Widget _buildPaletteButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: _openColorPalette,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }

  Widget _buildTextColorChip(OnboardingCardDraft d, String? hex) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDefault = hex == null;
    final isSelected =
        isDefault ? d.accentColor == null : d.accentColor == hex;
    final color = hex != null ? _parseHex(hex) : colorScheme.surfaceContainerHighest;

    return GestureDetector(
      onTap: () => _setTextColor(d, hex),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : colorScheme.outline.withValues(alpha: 0.4),
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: isDefault
            ? Icon(
                isSelected ? Icons.check_rounded : Icons.title_outlined,
                color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                size: 22,
              )
            : Center(
                child: Text(
                  'A',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color != null && color.computeLuminance() > 0.5
                        ? AppColors.textPrimary
                        : AppColors.textOnPrimary,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextPaletteButton(OnboardingCardDraft d) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _openCustomTextColorPicker(d),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}
