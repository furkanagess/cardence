import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/onboarding_card_draft.dart';

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

bool _hasValue(OnboardingCardDraft draft, String key) {
  final v = switch (key) {
    'email' => draft.email,
    'phone' => draft.phone,
    'company' => draft.company,
    'title' => draft.title,
    'website' => draft.website,
    'linkedin' => draft.linkedin,
    'skills' => draft.skills,
    'school' => draft.school,
    'about' => draft.about,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kartında Görünsün',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ön ve arka yüzde en fazla ${AppConstants.maxFrontCardFields} alan seç. Checkbox ile işaretle.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ön yüz',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'En fazla ${AppConstants.maxFrontCardFields} alan',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...OnboardingCardDraft.frontFieldKeys.where((key) => _hasValue(draft, key)).map((key) {
            final label = _fieldLabels[key] ?? key;
            final isSelected = draft.frontVisibleFields.contains(key);
            final canAdd = draft.frontVisibleFields.length < AppConstants.maxFrontCardFields;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (v) {
                    if (v == true && !canAdd) return;
                    final list = List<String>.from(draft.frontVisibleFields);
                    if (v == true) {
                      list.add(key);
                    } else {
                      list.remove(key);
                    }
                    onChanged(draft.copyWith(frontVisibleFields: list));
                  },
                  title: Text(label),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  dense: true,
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            'Arka yüz',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'En fazla ${AppConstants.maxBackCardFields} alan',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...OnboardingCardDraft.backFieldKeys.where((key) => _hasValue(draft, key)).map((key) {
            final label = _fieldLabels[key] ?? key;
            final isSelected = draft.backVisibleFields.contains(key);
            final canAdd = draft.backVisibleFields.length < AppConstants.maxBackCardFields;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (v) {
                    if (v == true && !canAdd) return;
                    final list = List<String>.from(draft.backVisibleFields);
                    if (v == true) {
                      list.add(key);
                    } else {
                      list.remove(key);
                    }
                    onChanged(draft.copyWith(backVisibleFields: list));
                  },
                  title: Text(label),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  dense: true,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
