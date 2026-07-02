import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/utils/intl_phone_field_helpers.dart';
import '../../../../core/validation/app_validators.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../onboarding/presentation/onboarding_name_helper.dart';
import '../../../onboarding/presentation/onboarding_validation.dart';
import '../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import 'auth_password_field.dart';
import 'register_legal_notice.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  final bool isLoading;
  final void Function({
    required String displayName,
    required String email,
    required String password,
    String? phone,
  }) onSubmit;

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _phoneNumber = '';
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_termsAccepted) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final displayName = OnboardingNameHelper.combine(firstName, lastName);
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final phone = _phoneNumber.trim();

    final firstNameError = OnboardingValidation.validateFirstName(context.l10n, firstName);
    final lastNameError = OnboardingValidation.validateLastName(context.l10n, lastName);
    String? emailError;
    String? phoneError;
    String? passwordError;
    if (!AppValidators.matches(AppValidators.email, email)) {
      emailError = 'Geçerli bir e-posta girin.';
    }
    phoneError = AppValidators.optionalPhoneError(phone);
    if (!AppValidators.isValidPassword(password)) {
      passwordError =
          'Şifre en az ${AppValidators.minPasswordLength} karakter olmalıdır.';
    }

    setState(() {
      _firstNameError = firstNameError;
      _lastNameError = lastNameError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
    });

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null) {
      return;
    }

    widget.onSubmit(
      displayName: displayName,
      email: email,
      password: password,
      phone: phone.isEmpty ? null : phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingFieldLabel(label: 'Ad', required: true),
        CustomTextField(
          controller: _firstNameController,
          hintText: context.l10n.rnMehmet,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: _firstNameError,
          onChanged: (_) {
            if (_firstNameError != null) {
              setState(() => _firstNameError = null);
            }
          },
        ),
        const SizedBox(height: 12),
        OnboardingFieldLabel(label: context.l10n.soyad, required: true),
        CustomTextField(
          controller: _lastNameController,
          hintText: context.l10n.rnYlmaz,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: _lastNameError,
          onChanged: (_) {
            if (_lastNameError != null) {
              setState(() => _lastNameError = null);
            }
          },
        ),
        const SizedBox(height: 12),
        OnboardingFieldLabel(label: context.l10n.ePosta, required: true),
        CustomTextField(
          controller: _emailController,
          hintText: context.l10n.ornekEmailCom,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: 12),
        OnboardingFieldLabel(label: context.l10n.telefon),
        IntlPhoneField(
          decoration: CustomTextField.themedDecoration(
            context,
            hintText: context.l10n.msg5xxXxxXxXx,
            errorText: _phoneError,
            prefixIcon: Icon(
              Icons.phone_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          initialCountryCode:
              IntlPhoneFieldHelpers.countryCodeFromPhone(_phoneNumber),
          initialValue: IntlPhoneFieldHelpers.nationalFromPhone(_phoneNumber),
          invalidNumberMessage: context.l10n.geerliBirTelefonNumarasGirin,
          onChanged: (phone) {
            _phoneNumber = phone.completeNumber;
            if (_phoneError != null) setState(() => _phoneError = null);
          },
        ),
        const SizedBox(height: 12),
        AuthPasswordField(
          controller: _passwordController,
          errorText: _passwordError,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: 14),
        RegisterLegalNotice(
          value: _termsAccepted,
          onChanged: (accepted) => setState(() => _termsAccepted = accepted),
        ),
        const SizedBox(height: 14),
        CustomButton(
          label: context.l10n.kaytOl,
          height: 48,
          isLoading: widget.isLoading,
          onPressed: _termsAccepted ? _submit : null,
        ),
      ],
    );
  }
}
