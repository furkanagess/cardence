import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/cardence_confirm_dialog.dart';
import '../../../../core/widgets/molecules/card_color_picker_sheet.dart';
import '../../../../core/widgets/molecules/card_index_circle_selector.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../plans/presentation/cubit/plan_cubit.dart';
import '../../../saved_cards/presentation/cubit/saved_cards_cubit.dart';
import '../../../saved_cards/presentation/wallet_paywall_flow.dart';
import '../card_customize_colors.dart';
import '../helpers/card_effect_premium_helper.dart';

/// Kart görünümü: önizleme, renk düzenlemesi ve yeni kart oluşturma.
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
  List<OnboardingCardDraft> _savedBaseline = [];
  int _selectedIndex = 0;
  bool _loading = true;
  bool _saving = false;
  static const double _carouselViewportFraction = 0.88;
  late final PageController _pageController =
      PageController(viewportFraction: _carouselViewportFraction);

  OnboardingCardDraft? get _draft => _cards.isEmpty
      ? null
      : _cards[_selectedIndex.clamp(0, _cards.length - 1)];

  bool get _hasUnsavedChanges {
    for (final card in _cards) {
      final cardId = card.cardId;
      if (cardId == null) return true;
      final baseline = _baselineFor(cardId);
      if (baseline == null || !card.contentEquals(baseline)) {
        return true;
      }
    }
    return false;
  }

  OnboardingCardDraft? _baselineFor(String cardId) {
    for (final card in _savedBaseline) {
      if (card.cardId == cardId) return card;
    }
    return null;
  }

  void _updateSelectedCard(OnboardingCardDraft updated) {
    final idx = _selectedIndex.clamp(0, _cards.length - 1);
    setState(() {
      _cards = List<OnboardingCardDraft>.from(_cards)..[idx] = updated;
    });
  }

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
      _savedBaseline = List<OnboardingCardDraft>.from(list);
      if (_selectedIndex >= _cards.length) {
        _selectedIndex = _cards.isEmpty ? 0 : _cards.length - 1;
      }
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

  static Color? _parseHex(String? hex) {
    if (hex == null || hex.length != 7 || !hex.startsWith('#')) return null;
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }

  void _setBackgroundColor(OnboardingCardDraft d, String? hex) {
    final updated = hex == null
        ? d.copyWith(clearBackgroundColor: true)
        : d.copyWith(backgroundColor: hex);
    _updateSelectedCard(updated);
  }

  void _setBackgroundColorFromPalette(OnboardingCardDraft d, String hex) {
    _updateSelectedCard(
      d.copyWith(backgroundColor: hex, lastUsedPaletteBackgroundColor: hex),
    );
  }

  void _setTextColor(OnboardingCardDraft d, String? hex) {
    final updated = hex == null
        ? d.copyWith(clearAccentColor: true)
        : d.copyWith(accentColor: hex);
    _updateSelectedCard(updated);
  }

  Future<bool> _confirmDiscardChanges() {
    return CardenceConfirmDialog.show(
      context,
      title: context.l10n.kaydedilmemiDeiiklikler,
      message: context.l10n.yaptnzDeiikliklerKaydedilmedikmakIstediinize,
      confirmLabel: context.l10n.k,
      cancelLabel: context.l10n.iptal,
      icon: Icons.warning_amber_rounded,
      confirmIsDestructive: true,
    ).then((value) => value == true);
  }

  Future<void> _save() async {
    if (_saving) return;

    final dirtyCards = _cards.where((card) {
      final cardId = card.cardId;
      if (cardId == null) return true;
      final baseline = _baselineFor(cardId);
      return baseline == null || !card.contentEquals(baseline);
    }).toList();

    if (dirtyCards.isEmpty) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    try {
      var nextCards = List<OnboardingCardDraft>.from(_cards);
      var nextBaseline = List<OnboardingCardDraft>.from(_savedBaseline);

      for (final card in dirtyCards) {
        final resolved = await prepareCardDraftForPersist(context, card);
        if (!mounted) return;
        if (resolved == null) {
          setState(() => _saving = false);
          return;
        }
        final synced = await widget.persistOnboardingCard(resolved);
        if (!mounted) return;

        final syncedId = synced.cardId;
        if (syncedId == null) continue;
        final cardIndex = nextCards.indexWhere((c) => c.cardId == syncedId);
        if (cardIndex >= 0) {
          nextCards[cardIndex] = synced;
        }
        final baselineIndex =
            nextBaseline.indexWhere((c) => c.cardId == syncedId);
        if (baselineIndex >= 0) {
          nextBaseline[baselineIndex] = synced;
        } else {
          nextBaseline = [...nextBaseline, synced];
        }
        widget.onDraftUpdated?.call(synced);
      }

      if (!mounted) return;
      setState(() {
        _cards = nextCards;
        _savedBaseline = nextBaseline;
        _saving = false;
      });
      Navigator.of(context).pop();
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openCustomTextColorPicker(OnboardingCardDraft d) async {
    final current = d.accentColor != null ? _parseHex(d.accentColor) : null;
    final bg = _parseHex(d.backgroundColor);
    final initialColor = current ??
        (bg != null
            ? (bg.computeLuminance() > 0.5
                ? AppColors.textPrimary
                : AppColors.surfaceLight)
            : AppColors.textPrimary);

    final applied = await CardColorPickerSheet.show(
      context,
      title: context.l10n.zelMetinRengi,
      initialColor: initialColor,
      editingBackground: false,
      previewBackgroundColor: d.backgroundColor,
      previewAccentColor: d.accentColor,
      previewBuilder: (previewBg, previewAccent) =>
          MyCardPreviewHelpers.flippableCardWithColors(
        draft: d,
        l10n: context.l10n,
        backgroundColor: previewBg,
        accentColor: previewAccent,
        cardEffect: d.cardEffect,
      ),
    );
    if (applied == null) return;

    _setTextColor(d, CardColorPickerSheet.colorToHex(applied));
  }

  Future<void> _createNewCard() async {
    final current = _draft ?? const OnboardingCardDraft();
    final newId = CardIdGenerator.generateBusinessCandidate();
    final copy = current.copyWith(
      cardId: newId,
      cardName: context.l10n.yeniKart,
      frontVisibleFields: current.shouldMigrateFrontFields
          ? List<String>.from(OnboardingCardDraft.defaultFrontVisibleFields)
          : List.from(current.frontVisibleFields),
      backVisibleFields: current.backVisibleFields.isEmpty
          ? List<String>.from(OnboardingCardDraft.defaultBackVisibleFields)
          : List.from(current.backVisibleFields),
    );
    final synced = await widget.persistOnboardingCard(copy);
    if (!mounted) return;
    await _loadCards();
    final idx = _cards.indexWhere((c) => c.cardId == synced.cardId);
    if (idx >= 0) setState(() => _selectedIndex = idx);
    widget.onDraftUpdated?.call(synced);
  }

  Future<void> _openPaywallForLockedSlot() async {
    try {
      final cubit = context.read<SavedCardsCubit>();
      await WalletPaywallFlow.show(context, cubit: cubit);
      if (!mounted) return;
      await context.read<PlanCubit>().refresh();
    } catch (_) {
      // Paywall sağlayıcıları bu rotada yoksa sessizce çık.
    }
    if (mounted) await _loadCards();
  }

  void _selectCardIndex(int index) {
    if (index < 0 || index >= _cards.length) return;
    setState(() => _selectedIndex = index);
    if (_pageController.hasClients && _cards.length > 1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _openColorPalette() async {
    final d = _draft;
    if (d == null) return;
    final currentBg = _parseHex(d.backgroundColor);
    final lastUsed = d.lastUsedPaletteBackgroundColor != null
        ? _parseHex(d.lastUsedPaletteBackgroundColor!)
        : null;
    final initialColor = currentBg ?? lastUsed ?? AppColors.surfaceLight;

    final applied = await CardColorPickerSheet.show(
      context,
      title: context.l10n.zelKartRengi,
      initialColor: initialColor,
      editingBackground: true,
      previewBackgroundColor: d.backgroundColor,
      previewAccentColor: d.accentColor,
      previewBuilder: (previewBg, previewAccent) =>
          MyCardPreviewHelpers.flippableCardWithColors(
        draft: d,
        l10n: context.l10n,
        backgroundColor: previewBg,
        accentColor: previewAccent,
        cardEffect: d.cardEffect,
      ),
    );
    if (applied == null) return;

    _setBackgroundColorFromPalette(d, CardColorPickerSheet.colorToHex(applied));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_loading) {
      return CardenceScaffold(
        appBar: CardenceAppBar(title: context.l10n.kartGrnm),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_cards.isEmpty) {
      return CardenceScaffold(
        appBar: CardenceAppBar(title: context.l10n.kartGrnm),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.credit_card_off_rounded,
                    size: 64,
                    color: colorScheme.outline.withValues(alpha: 0.6)),
                const SizedBox(height: 16),
                Text(
                  context.l10n.henzKartYok,
                  style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.profilBilgileriniziDoldurupIlkKartnz,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: context.l10n.yeniKartOlutur,
                  icon: Icons.add_rounded,
                  onPressed: _createNewCard,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
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

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !_hasUnsavedChanges) return;
        final shouldLeave = await _confirmDiscardChanges();
        if (!mounted || !shouldLeave) return;
        Navigator.of(context).pop();
      },
      child: CardenceScaffold(
        appBar: CardenceAppBar(title: context.l10n.kartGrnm),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        cardHorizontalPadding,
                        0,
                        8,
                        0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: FlippablePersonCard.cardAspectRatio,
                                child: isCarousel
                                    ? PageView.builder(
                                        controller: _pageController,
                                        itemCount: _cards.length,
                                        onPageChanged: (index) => setState(
                                          () => _selectedIndex = index,
                                        ),
                                        padEnds: false,
                                        itemBuilder: (context, index) {
                                          final draft = _cards[index];

                                          return AnimatedBuilder(
                                            animation: _pageController,
                                            builder: (context, child) {
                                              double t = 0;
                                              if (_pageController
                                                  .position.haveDimensions) {
                                                final page =
                                                    _pageController.page ??
                                                        _pageController
                                                            .initialPage
                                                            .toDouble();
                                                t = (page - index)
                                                    .abs()
                                                    .clamp(0.0, 1.0);
                                              }
                                              const maxScaleDelta = 0.06;
                                              const maxFadeDelta = 0.2;
                                              final scale =
                                                  1.0 - (t * maxScaleDelta);
                                              final opacity =
                                                  1.0 - (t * maxFadeDelta);

                                              return Opacity(
                                                opacity: opacity,
                                                child: Transform.scale(
                                                  scale: scale,
                                                  child: child,
                                                ),
                                              );
                                            },
                                            child: MyCardPreviewHelpers
                                                .flippableCard(
                                              draft: draft,
                                              l10n: context.l10n,
                                              emptyMessage:
                                                  context.l10n.kartBilgisiYok,
                                            ),
                                          );
                                        },
                                      )
                                    : MyCardPreviewHelpers.flippableCard(
                                        draft: d,
                                        l10n: context.l10n,
                                        emptyMessage:
                                            context.l10n.kartBilgisiYok,
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CardIndexCircleSelector(
                            unlockedCount: _cards.length,
                            selectedIndex: _selectedIndex,
                            onSelected: _selectCardIndex,
                            onLockedTap: _openPaywallForLockedSlot,
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
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
                      _buildColorChip(d, null),
                      ...cardBackgroundColorOptions
                          .map((hex) => _buildColorChip(d, hex)),
                      if (hasLastUsed &&
                          d.lastUsedPaletteBackgroundColor != null)
                        _buildColorChip(d, d.lastUsedPaletteBackgroundColor!),
                      _buildPaletteButton(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    context.l10n.metinRengi2,
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
                      _buildTextColorChip(d, null),
                      ...cardTextColorOptions
                          .map((hex) => _buildTextColorChip(d, hex)),
                      _buildTextPaletteButton(d),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    label: context.l10n.kaydet,
                    onPressed: _hasUnsavedChanges && !_saving ? _save : null,
                    isLoading: _saving,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildColorChip(OnboardingCardDraft d, String? hex) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDefault = hex == null;
    final isSelected =
        isDefault ? d.backgroundColor == null : d.backgroundColor == hex;
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
            color: isSelected
                ? AppColors.primary
                : colorScheme.outline.withValues(alpha: 0.4),
            width: isSelected ? 3 : 1.5,
          ),
        ),
        child: isDefault
            ? Icon(isSelected ? Icons.check_rounded : Icons.palette_outlined,
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
                size: 22)
            : (isSelected && color != null && color.computeLuminance() > 0.5)
                ? Icon(Icons.check_rounded,
                    color: AppColors.textPrimary, size: 22)
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
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.palette_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildTextColorChip(OnboardingCardDraft d, String? hex) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDefault = hex == null;
    final isSelected = isDefault ? d.accentColor == null : d.accentColor == hex;
    final color =
        hex != null ? _parseHex(hex) : colorScheme.surfaceContainerHighest;

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
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
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
        child: SizedBox(
          width: 48,
          height: 48,
          child:
              Icon(Icons.palette_outlined, color: AppColors.primary, size: 22),
        ),
      ),
    );
  }
}
