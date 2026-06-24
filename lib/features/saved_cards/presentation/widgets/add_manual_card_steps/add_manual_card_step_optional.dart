import 'package:flutter/material.dart';
import '../../../../../core/l10n/l10n_extensions.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../../../core/widgets/molecules/skills_chip_input.dart';
import '../../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import '../../../domain/entities/manual_saved_card_draft.dart';
import '../../manual_card_phone_helper.dart';

class AddManualCardStepOptional extends StatefulWidget {
  const AddManualCardStepOptional({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final ManualSavedCardDraft draft;
  final ValueChanged<ManualSavedCardDraft> onChanged;

  @override
  State<AddManualCardStepOptional> createState() =>
      _AddManualCardStepOptionalState();
}

class _AddManualCardStepOptionalState extends State<AddManualCardStepOptional> {
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _linkedinController;
  late final TextEditingController _aboutController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.draft.email ?? '');
    _websiteController =
        TextEditingController(text: widget.draft.website ?? '');
    _linkedinController =
        TextEditingController(text: widget.draft.linkedin ?? '');
    _aboutController = TextEditingController(text: widget.draft.about ?? '');
    _noteController = TextEditingController(text: widget.draft.note ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _aboutController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OnboardingStepShell(
      subtitle: context.l10n.iletiimProfilVeKiiselNot,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingFieldLabel(label: context.l10n.ePosta, required: true),
          CustomTextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.next,
            hintText: context.l10n.isimSirketCom,
            prefixIcon: Icon(
              Icons.mail_outline_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                email: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.telefon),
          IntlPhoneField(
            initialCountryCode:
                ManualCardPhoneHelper.countryCodeFromPhone(widget.draft.phone),
            initialValue:
                ManualCardPhoneHelper.nationalFromPhone(widget.draft.phone),
            showCountryFlag: true,
            decoration: CustomTextField.themedDecoration(
              context,
              hintText: context.l10n.msg5xxXxxXxXx2,
            ),
            onChanged: (phone) => widget.onChanged(
              widget.draft.copyWith(
                phone: phone.number.isEmpty ? null : phone.completeNumber,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.webSitesi),
          CustomTextField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            hintText: context.l10n.wwwSirketCom,
            prefixIcon: Icon(
              Icons.language_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                website: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.linkedin),
          CustomTextField(
            controller: _linkedinController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            hintText: context.l10n.linkedinComInKullanici,
            prefixIcon: Icon(
              Icons.link_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                linkedin: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.hakkmda),
          CustomTextField(
            controller: _aboutController,
            minLines: 3,
            maxLines: 5,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            hintText: context.l10n.kartSahibiHakkndaKsaBilgi,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                about: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.beceriler),
          SkillsChipInput(
            label: '',
            hintText: context.l10n.beceriEkle,
            value: widget.draft.skills,
            onChanged: (skills) => widget.onChanged(
              widget.draft.copyWith(
                skills: (skills ?? '').trim().isEmpty ? null : skills,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OnboardingFieldLabel(label: context.l10n.not),
          CustomTextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            hintText: context.l10n.buKiiHakkndaEklemekIstediiniz,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(
                note: value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
