import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/helpers/card_visibility_helper.dart';
import '../../domain/entities/onboarding_card_draft.dart';

Map<String, String> _fieldLabels(AppLocalizations l10n) => {
      'email': l10n.ePosta,
      'phone': l10n.telefon,
      'linkedin': l10n.linkedin,
      'website': l10n.webSitesi,
      'skills': l10n.yetenekler,
    };

bool _hasValue(OnboardingCardDraft draft, String key) {
  final v = switch (key) {
    'email' => draft.email,
    'phone' => draft.phone,
    'linkedin' => draft.linkedin,
    'website' => draft.website,
    'skills' => draft.skills,
    _ => null,
  };
  return v != null && v.trim().isNotEmpty;
}

class OnboardingStepVisibleFields extends StatelessWidget {
  const OnboardingStepVisibleFields({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = _fieldLabels(l10n);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.kartndaGrnsn,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.nYzdeIletiimBilgileriniEn,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.nYzIletiim,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...OnboardingCardDraft.cardFrontContactFieldKeys
              .where((key) => _hasValue(draft, key))
              .map((key) {
            final label = labels[key] ?? key;
            final isSelected =
                draft.resolvedFrontContactFields.contains(key);
            final atLimit = draft.resolvedFrontContactFields.length >=
                AppConstants.maxFrontCardFields;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: isSelected || !atLimit
                      ? (v) {
                          final list =
                              List<String>.from(draft.frontVisibleFields);
                          if (v == true) {
                            if (!list.contains(key)) list.add(key);
                          } else {
                            list.remove(key);
                          }
                          onChanged(
                            draft.copyWith(
                              frontVisibleFields:
                                  CardVisibilityHelper.normalizeFrontContactFields(
                                list,
                              ),
                            ),
                          );
                        }
                      : null,
                  title: Text(label),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  dense: true,
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            l10n.arkaYz,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.hakkmdaHerZamanGsterilir,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (_hasValue(draft, 'skills'))
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: CheckboxListTile(
                value: draft.showSkillsOnBack,
                onChanged: (v) {
                  final list = List<String>.from(draft.backVisibleFields);
                  if (v == true) {
                    if (!list.contains('skills')) list.add('skills');
                  } else {
                    list.remove('skills');
                  }
                  onChanged(draft.copyWith(backVisibleFields: list));
                },
                title: Text(l10n.yetenekler),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                dense: true,
              ),
            ),
        ],
      ),
    );
  }
}
