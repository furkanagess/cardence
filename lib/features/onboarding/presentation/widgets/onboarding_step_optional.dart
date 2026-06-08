import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../core/widgets/molecules/skills_chip_input.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import 'onboarding_step_shell.dart';

/// İsteğe bağlı iletişim ve profil alanları (tek adımda).
class OnboardingStepOptional extends StatefulWidget {
  const OnboardingStepOptional({
    super.key,
    required this.draft,
    required this.onChanged,
    required this.stepIndex,
    required this.stepCount,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;
  final int stepIndex;
  final int stepCount;

  @override
  State<OnboardingStepOptional> createState() => _OnboardingStepOptionalState();
}

class _OnboardingStepOptionalState extends State<OnboardingStepOptional> {
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _schoolController;
  late final TextEditingController _aboutController;

  @override
  void initState() {
    super.initState();
    _websiteController =
        TextEditingController(text: widget.draft.website ?? '');
    _linkedinController =
        TextEditingController(text: widget.draft.linkedin ?? '');
    _schoolController =
        TextEditingController(text: widget.draft.school ?? '');
    _aboutController =
        TextEditingController(text: widget.draft.about ?? '');
  }

  @override
  void dispose() {
    _websiteController.dispose();
    _linkedinController.dispose();
    _schoolController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  static String _countryCodeFromPhone(String? full) {
    if (full == null || full.isEmpty) return 'TR';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90')) return 'TR';
    if (digits.startsWith('1')) return 'US';
    if (digits.startsWith('44')) return 'GB';
    if (digits.startsWith('49')) return 'DE';
    if (digits.startsWith('33')) return 'FR';
    return 'TR';
  }

  static String _nationalFromPhone(String? full) {
    if (full == null || full.isEmpty) return '';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('1') && digits.length > 1) {
      return digits.substring(1);
    }
    if (digits.startsWith('44') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('49') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('33') && digits.length > 2) {
      return digits.substring(2);
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepShell(
      title: 'Ek bilgiler',
      optionalHint: 'Opsiyonel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingFieldLabel(label: 'Telefon'),
          IntlPhoneField(
            initialCountryCode: _countryCodeFromPhone(widget.draft.phone),
            initialValue: _nationalFromPhone(widget.draft.phone),
            showCountryFlag: true,
            decoration: CustomTextField.themedDecoration(
              context,
              hintText: 'Telefon numaranız',
            ),
            onChanged: (phone) => widget.onChanged(
              widget.draft.copyWith(
                phone: phone.number.isEmpty ? null : phone.completeNumber,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'Web sitesi'),
          CustomTextField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            hintText: 'https://sirketiniz.com',
            prefixIcon: const Icon(Icons.language_outlined),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(website: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'LinkedIn'),
          CustomTextField(
            controller: _linkedinController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            hintText: 'LinkedIn profil linki',
            prefixIcon: const Icon(Icons.link_rounded),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(linkedin: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'Yetenekler'),
          SkillsChipInput(
            label: '',
            hintText: 'Yetenek ekle (örn. Flutter)',
            value: widget.draft.skills,
            onChanged: (s) => widget.onChanged(
              widget.draft.copyWith(
                skills: (s ?? '').trim().isEmpty ? null : s,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'Okul'),
          CustomTextField(
            controller: _schoolController,
            textCapitalization: TextCapitalization.words,
            hintText: 'Örn. İstanbul Üniversitesi',
            prefixIcon: const Icon(Icons.school_outlined),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(school: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          const OnboardingFieldLabel(label: 'Hakkımda'),
          CustomTextField(
            controller: _aboutController,
            minLines: 3,
            maxLines: 5,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            hintText: 'Kısaca kendinizi tanıtın',
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(about: value.isEmpty ? null : value),
            ),
          ),
        ],
      ),
    );
  }
}
