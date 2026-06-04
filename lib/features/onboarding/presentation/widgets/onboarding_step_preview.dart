import 'package:flutter/material.dart';

import '../../../../core/widgets/organisms/person_info_card.dart';
import '../../domain/entities/onboarding_card_draft.dart';

/// Alan adı -> kısa etiket (önizlemede gösterim için).
String _label(String key) {
  switch (key) {
    case 'displayName':
      return 'Ad';
    case 'email':
      return 'E-posta';
    case 'phone':
      return 'Telefon';
    case 'company':
      return 'Şirket';
    case 'title':
      return 'Ünvan';
    case 'website':
      return 'Web';
    case 'linkedin':
      return 'LinkedIn';
    case 'skills':
      return 'Yetenekler';
    case 'school':
      return 'Okul';
    case 'about':
      return 'Hakkımda';
    default:
      return key;
  }
}

String? _value(OnboardingCardDraft draft, String fieldKey) {
  switch (fieldKey) {
    case 'displayName':
      return draft.displayName;
    case 'email':
      return draft.email;
    case 'phone':
      return draft.phone;
    case 'company':
      return draft.company;
    case 'title':
      return draft.title;
    case 'website':
      return draft.website;
    case 'linkedin':
      return draft.linkedin;
    case 'skills':
      return draft.skills;
    case 'school':
      return draft.school;
    case 'about':
      return draft.about;
    default:
      return null;
  }
}

class OnboardingStepPreview extends StatelessWidget {
  const OnboardingStepPreview({
    super.key,
    required this.draft,
  });

  final OnboardingCardDraft draft;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final frontKeys = draft.resolvedFrontVisibleFields
        .take(3)
        .toList();
    final backKeys = draft.backVisibleFields.isEmpty
        ? OnboardingCardDraft.backFieldKeys.take(3).toList()
        : draft.backVisibleFields.take(3).toList();
    final allKeys = [...frontKeys, ...backKeys].toSet().toList();
    final entries = allKeys
        .where((key) => key != 'displayName')
        .map((key) => (label: _label(key), value: _value(draft, key)))
        .where((e) => e.value != null && e.value!.trim().isNotEmpty)
        .map((e) => (label: e.label, value: e.value!))
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kartın önizlemesi',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kartın böyle görünecek. İstersen geri dönüp düzenleyebilirsin.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          PersonInfoCard(
            title: draft.displayName?.trim().isEmpty ?? true
                ? 'Ad'
                : draft.displayName,
            entries: entries,
            emptyMessage: 'Henüz bilgi eklenmedi',
          ),
        ],
      ),
    );
  }
}
