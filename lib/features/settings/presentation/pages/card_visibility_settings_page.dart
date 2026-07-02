import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/constants/app_constants.dart';
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
import '../../../onboarding/domain/helpers/card_visibility_helper.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';
import '../widgets/card_appearance_section_card.dart';
import '../widgets/card_visibility_toggle_chip.dart';
import '../../../my_cards/presentation/helpers/card_effect_premium_helper.dart';

/// Kart ön/arka yüz görünümü: renk, metin rengi ve alan seçimi.
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
  static const double _saveBarContentHeight = 48;
  static const double _saveBarVerticalPadding = 16;

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

  void _toggleFrontField(String key) {
    final draft = _draft;
    if (draft == null) return;
    if (!CardVisibilityHelper.hasValue(draft, key)) return;

    final list = List<String>.from(draft.frontVisibleFields);
    final isSelected = draft.resolvedFrontContactFields.contains(key);

    if (isSelected) {
      list.remove(key);
    } else if (list.length < AppConstants.maxFrontCardFields) {
      if (!list.contains(key)) list.add(key);
    } else {
      return;
    }

    _updateDraft(
      draft.copyWith(
        frontVisibleFields:
            CardVisibilityHelper.normalizeFrontContactFields(list),
      ),
    );
  }

  void _toggleBackField(String key) {
    final draft = _draft;
    if (draft == null) return;
    if (!CardVisibilityHelper.hasValue(draft, key)) return;

    final list = List<String>.from(draft.backVisibleFields);
    final isSelected = list.contains(key);

    if (isSelected) {
      list.remove(key);
    } else if (list.length < AppConstants.maxBackCardFields) {
      list.add(key);
    } else {
      return;
    }

    _updateDraft(
      draft.copyWith(
        backVisibleFields: CardVisibilityHelper.normalizeBackFields(list),
      ),
    );
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
        _saveBarVerticalPadding +
        _saveBarContentHeight +
        _saveBarVerticalPadding;
  }

  Widget _buildStickySaveBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          0,
          20,
          _saveBarVerticalPadding,
        ),
        child: Material(
          color: Colors.transparent,
          child: CustomButton(
            label: context.l10n.kaydet,
            onPressed: _saving ? null : _save,
            isLoading: _saving,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 8,
              shadowColor: AppColors.primary.withValues(alpha: 0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
    final frontSelected = draft.resolvedFrontContactFields;
    final frontAtLimit = frontSelected.length >= AppConstants.maxFrontCardFields;
    final backSelected = draft.backVisibleFields;
    final backAtLimit = backSelected.length >= AppConstants.maxBackCardFields;
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
                  child:                   CardColorCustomizeSection(
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
                const SizedBox(height: 12),
                CardAppearanceSectionCard(
                  title: context.l10n.nYzdeGster,
                  subtitle: 'En fazla ${AppConstants.maxFrontCardFields}',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final key
                          in OnboardingCardDraft.cardFrontContactFieldKeys)
                        CardVisibilityToggleChip(
                          label:
                              CardVisibilityHelper.contactFieldLabels[key] ??
                                  key,
                          selected: frontSelected.contains(key),
                          enabled: CardVisibilityHelper.hasValue(draft, key) &&
                              (frontSelected.contains(key) || !frontAtLimit),
                          onTap: () => _toggleFrontField(key),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                CardAppearanceSectionCard(
                  title: context.l10n.arkaYzdeGster,
                  subtitle: 'En fazla ${AppConstants.maxBackCardFields}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.hakkmdaHerZamanGsterilir,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final key in OnboardingCardDraft.backFieldKeys)
                            CardVisibilityToggleChip(
                              label: CardVisibilityHelper
                                      .backFieldLabels[key] ??
                                  key,
                              selected: backSelected.contains(key),
                              enabled:
                                  CardVisibilityHelper.hasValue(draft, key) &&
                                      (backSelected.contains(key) ||
                                          !backAtLimit),
                              onTap: () => _toggleBackField(key),
                            ),
                        ],
                      ),
                    ],
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
