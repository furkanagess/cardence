import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/molecules/card_color_customize_section.dart';
import '../../../../core/widgets/molecules/card_effect_customize_section.dart';
import '../../../../core/domain/card_visual_effect.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../my_cards/presentation/widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../widgets/card_appearance_section_card.dart';
import '../../../my_cards/presentation/helpers/card_effect_premium_helper.dart';

/// Kart görünümü: renk, metin rengi ve kart efekti.
class CardVisibilitySettingsPage extends StatefulWidget {
  const CardVisibilitySettingsPage({
    super.key,
    required this.getOnboardingDraftCards,
    required this.persistOnboardingCard,
    this.onDraftUpdated,
  });

  final GetOnboardingDraftCards getOnboardingDraftCards;
  final PersistOnboardingCard persistOnboardingCard;
  final ValueChanged<OnboardingCardDraft>? onDraftUpdated;

  @override
  State<CardVisibilitySettingsPage> createState() =>
      _CardVisibilitySettingsPageState();
}

class _CardVisibilitySettingsPageState extends State<CardVisibilitySettingsPage> {
  static const double _saveBarTopPadding = 12;
  static const double _saveBarContentHeight = 48;
  static const double _saveBarBottomPadding = 16;

  List<OnboardingCardDraft> _cards = [];
  int _selectedIndex = 0;
  bool _loading = true;
  bool _saving = false;

  OnboardingCardDraft? get _draft =>
      _cards.isEmpty ? null : _cards[_selectedIndex.clamp(0, _cards.length - 1)];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final list = await widget.getOnboardingDraftCards();
    if (!mounted) return;
    setState(() {
      _cards = list;
      if (_selectedIndex >= _cards.length) {
        _selectedIndex = _cards.isEmpty ? 0 : _cards.length - 1;
      }
      _loading = false;
    });
  }

  void _updateDraft(OnboardingCardDraft updated) {
    final idx = _selectedIndex.clamp(0, _cards.length - 1);
    setState(() {
      _cards = List<OnboardingCardDraft>.from(_cards)..[idx] = updated;
    });
  }

  void _setBackgroundColor(String? hex) {
    final draft = _draft;
    if (draft == null) return;
    _updateDraft(
      hex == null
          ? draft.copyWith(clearBackgroundColor: true)
          : draft.copyWith(backgroundColor: hex),
    );
  }

  void _setBackgroundFromPalette(String hex) {
    final draft = _draft;
    if (draft == null) return;
    _updateDraft(
      draft.copyWith(
        backgroundColor: hex,
        lastUsedPaletteBackgroundColor: hex,
      ),
    );
  }

  void _setAccentColor(String? hex) {
    final draft = _draft;
    if (draft == null) return;
    _updateDraft(
      hex == null
          ? draft.copyWith(clearAccentColor: true)
          : draft.copyWith(accentColor: hex),
    );
  }

  void _setCardEffect(CardVisualEffect effect) {
    final draft = _draft;
    if (draft == null) return;
    _updateDraft(draft.copyWith(cardEffect: effect));
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null || _saving) return;

    setState(() => _saving = true);
    try {
      final resolved = await prepareCardDraftForPersist(context, draft);
      if (!mounted) return;
      if (resolved == null) {
        setState(() => _saving = false);
        return;
      }
      if (resolved.cardEffect != draft.cardEffect) {
        _updateDraft(resolved);
      }
      final synced = await widget.persistOnboardingCard(resolved);
      if (!mounted) return;
      widget.onDraftUpdated?.call(synced);
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  double _saveBarInset(BuildContext context) {
    return MediaQuery.paddingOf(context).bottom +
        _saveBarTopPadding +
        _saveBarContentHeight +
        _saveBarBottomPadding;
  }

  Widget _buildStickySaveBar(BuildContext context) {
    return CardenceFlowBottomBarRegion(
      child: CustomButton(
        label: context.l10n.kaydet,
        onPressed: _saving ? null : _save,
        isLoading: _saving,
        height: _saveBarContentHeight,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return CardenceScaffold(
        appBar: CardenceAppBar(title: context.l10n.kartGrnm2),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_draft == null) {
      return CardenceScaffold(
        appBar: CardenceAppBar(title: context.l10n.kartGrnm2),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              context.l10n.henzKartnzYokProfildenKart,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final draft = _draft!;
    final bottomInset = _saveBarInset(context);

    return CardenceScaffold(
      appBar: CardenceAppBar(title: context.l10n.kartGrnm2),
      body: Stack(
        fit: StackFit.expand,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 32 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_cards.length > 1) ...[
                  Text(
                    context.l10n.kart,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: ValueKey(_selectedIndex),
                    value: _selectedIndex.clamp(0, _cards.length - 1),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: List.generate(_cards.length, (index) {
                      return DropdownMenuItem(
                        value: index,
                        child: Text(_cards[index].listTitle),
                      );
                    }),
                    onChanged: (index) {
                      if (index == null) return;
                      setState(() => _selectedIndex = index);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                AspectRatio(
                  aspectRatio: FlippablePersonCard.cardAspectRatio,
                  child: MyCardPreviewHelpers.flippableCard(
                    draft: draft,
                    l10n: context.l10n,
                    emptyMessage: context.l10n.nizleme,
                    showActionStrip: false,
                  ),
                ),
                const SizedBox(height: 20),
                CardAppearanceSectionCard(
                  title: context.l10n.kartRengi2,
                  trailing: Icon(
                    Icons.palette_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  child: CardColorCustomizeSection(
                    backgroundColor: draft.backgroundColor,
                    accentColor: draft.accentColor,
                    lastUsedPaletteBackgroundColor:
                        draft.lastUsedPaletteBackgroundColor,
                    previewBuilder: (bg, accent) =>
                        MyCardPreviewHelpers.flippableCardWithColors(
                      draft: draft,
                      l10n: context.l10n,
                      backgroundColor: bg,
                      accentColor: accent,
                      cardEffect: draft.cardEffect,
                      emptyMessage: context.l10n.nizleme,
                      showActionStrip: false,
                    ),
                    showTextSection: false,
                    onBackgroundColorChanged: _setBackgroundColor,
                    onAccentColorChanged: _setAccentColor,
                    onLastUsedPaletteBackgroundChanged:
                        _setBackgroundFromPalette,
                  ),
                ),
                const SizedBox(height: 12),
                CardAppearanceSectionCard(
                  title: context.l10n.metinRengi2,
                  child: CardColorCustomizeSection(
                    backgroundColor: draft.backgroundColor,
                    accentColor: draft.accentColor,
                    previewBuilder: (bg, accent) =>
                        MyCardPreviewHelpers.flippableCardWithColors(
                      draft: draft,
                      l10n: context.l10n,
                      backgroundColor: bg,
                      accentColor: accent,
                      cardEffect: draft.cardEffect,
                      emptyMessage: context.l10n.nizleme,
                      showActionStrip: false,
                    ),
                    showBackgroundSection: false,
                    useAutomaticTextPill: true,
                    onBackgroundColorChanged: _setBackgroundColor,
                    onAccentColorChanged: _setAccentColor,
                  ),
                ),
                const SizedBox(height: 12),
                CardAppearanceSectionCard(
                  title: context.l10n.kartEfekti,
                  trailing: Icon(
                    Icons.auto_awesome_outlined,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  child: CardEffectCustomizeSection(
                    selectedEffect: draft.cardEffect,
                    onEffectChanged: _setCardEffect,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickySaveBar(context),
          ),
        ],
      ),
    );
  }
}
