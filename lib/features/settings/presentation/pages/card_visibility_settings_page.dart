import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/atoms/cardence_app_bar.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/organisms/cardence_scaffold.dart';
import '../../../../core/widgets/organisms/flippable_person_card.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../my_cards/presentation/widgets/my_card_preview_helpers.dart';
import '../../../onboarding/domain/entities/onboarding_card_draft.dart';
import '../../../onboarding/domain/helpers/card_visibility_helper.dart';
import '../../../onboarding/domain/usecases/get_onboarding_draft_cards.dart';

/// Kart ön/arka yüz görünürlük ayarları.
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

  void _toggleFrontField(String key, bool selected) {
    final draft = _draft;
    if (draft == null) return;

    final list = List<String>.from(draft.frontVisibleFields);
    if (selected) {
      if (!list.contains(key) &&
          list.length < AppConstants.maxFrontCardFields) {
        list.add(key);
      }
    } else {
      list.remove(key);
    }

    _updateDraft(
      draft.copyWith(
        frontVisibleFields:
            CardVisibilityHelper.normalizeFrontContactFields(list),
      ),
    );
  }

  void _toggleBackSkills(bool selected) {
    final draft = _draft;
    if (draft == null) return;

    final list = List<String>.from(draft.backVisibleFields);
    if (selected) {
      if (!list.contains('skills')) list.add('skills');
    } else {
      list.remove('skills');
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
      final synced = await widget.persistOnboardingCard(draft);
      if (!mounted) return;
      widget.onDraftUpdated?.call(synced);
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_loading) {
      return CardenceScaffold(
        appBar: const CardenceAppBar(title: 'Kart görünümü'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_draft == null) {
      return CardenceScaffold(
        appBar: const CardenceAppBar(title: 'Kart görünümü'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Henüz kartınız yok. Profilden kart oluşturduktan sonra görünürlük ayarlarını yapabilirsiniz.',
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

    return CardenceScaffold(
      appBar: const CardenceAppBar(title: 'Kart görünümü'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_cards.length > 1) ...[
                    Text(
                      'Kart',
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
                        final card = _cards[index];
                        return DropdownMenuItem(
                          value: index,
                          child: Text(card.listTitle),
                        );
                      }),
                      onChanged: (index) {
                        if (index == null) return;
                        setState(() => _selectedIndex = index);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                  AspectRatio(
                    aspectRatio: FlippablePersonCard.cardAspectRatio,
                    child: MyCardPreviewHelpers.flippableCard(
                      draft: draft,
                      emptyMessage: 'Önizleme',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Ön yüz — iletişim',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kartın alt kısmında hangi iletişim bilgilerinin görüneceğini seçin (en fazla 3).',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...OnboardingCardDraft.cardFrontContactFieldKeys.map((key) {
                    final label =
                        CardVisibilityHelper.contactFieldLabels[key] ?? key;
                    final hasValue = CardVisibilityHelper.hasValue(draft, key);
                    final isSelected =
                        draft.resolvedFrontContactFields.contains(key);
                    final atLimit = draft.resolvedFrontContactFields.length >=
                        AppConstants.maxFrontCardFields;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _VisibilityToggleTile(
                        label: label,
                        subtitle: hasValue
                            ? null
                            : 'Profilde bu alanı doldurun',
                        value: isSelected,
                        enabled: hasValue && (isSelected || !atLimit),
                        onChanged: (value) => _toggleFrontField(key, value),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  Text(
                    'Arka yüz',
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hakkımda her zaman gösterilir. İsterseniz yeteneklerinizi de ekleyebilirsiniz.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _VisibilityToggleTile(
                    label: 'Yetenekler',
                    subtitle: CardVisibilityHelper.hasValue(draft, 'skills')
                        ? null
                        : 'Profilde yeteneklerinizi ekleyin',
                    value: draft.showSkillsOnBack,
                    enabled: CardVisibilityHelper.hasValue(draft, 'skills'),
                    onChanged: _toggleBackSkills,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: CustomButton(
                label: 'Kaydet',
                isLoading: _saving,
                enabled: !_saving,
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityToggleTile extends StatelessWidget {
  const _VisibilityToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.enabled = true,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: SwitchListTile(
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
        title: Text(label),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
