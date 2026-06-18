import 'package:flutter/material.dart';

import '../../domain/entities/onboarding_card_draft.dart';

const Map<String, String> _fieldLabels = {
  'email': 'E-posta',
  'phone': 'Telefon',
  'linkedin': 'LinkedIn',
  'website': 'Web sitesi',
  'skills': 'Yetenekler',
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
            'Ön yüzde iletişim bilgilerini, arka yüzde isteğe bağlı yetenekleri seç.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Ön yüz — iletişim',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...OnboardingCardDraft.cardFrontContactFieldKeys
              .where((key) => _hasValue(draft, key))
              .map((key) {
            final label = _fieldLabels[key] ?? key;
            final isSelected =
                draft.resolvedFrontContactFields.contains(key);
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
                  onChanged: (v) {
                    final list = List<String>.from(draft.frontVisibleFields);
                    if (v == true) {
                      if (!list.contains(key)) list.add(key);
                    } else {
                      list.remove(key);
                    }
                    onChanged(draft.copyWith(frontVisibleFields: list));
                  },
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
            'Arka yüz',
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hakkımda her zaman gösterilir.',
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
                title: const Text('Yetenekler'),
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
