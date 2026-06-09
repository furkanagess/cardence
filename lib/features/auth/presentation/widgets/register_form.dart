import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/validation/app_validators.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../onboarding/presentation/onboarding_name_helper.dart';
import '../../../onboarding/presentation/onboarding_validation.dart';
import '../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import 'auth_password_field.dart';

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
  final _confirmPasswordController = TextEditingController();
  String _phoneNumber = '';
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    final displayName = OnboardingNameHelper.combine(firstName, lastName);
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final phone = _phoneNumber.trim();

    final firstNameError = OnboardingValidation.validateFirstName(firstName);
    final lastNameError = OnboardingValidation.validateLastName(lastName);
    String? emailError;
    String? phoneError;
    String? passwordError;
    String? confirmPasswordError;
    if (!AppValidators.matches(AppValidators.email, email)) {
      emailError = 'Geçerli bir e-posta girin.';
    }
    if (phone.isNotEmpty && phone.length < 8) {
      phoneError = 'Geçerli bir telefon numarası girin.';
    }
    if (!AppValidators.isValidPassword(password)) {
      passwordError =
          'Şifre en az ${AppValidators.minPasswordLength} karakter olmalıdır.';
    }
    if (password != confirmPassword) {
      confirmPasswordError = 'Şifreler eşleşmiyor.';
    }

    setState(() {
      _firstNameError = firstNameError;
      _lastNameError = lastNameError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    if (firstNameError != null ||
        lastNameError != null ||
        emailError != null ||
        phoneError != null ||
        passwordError != null ||
        confirmPasswordError != null) {
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
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OnboardingFieldLabel(label: 'Ad', required: true),
        CustomTextField(
          controller: _firstNameController,
          hintText: 'Örn. Ayşe',
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: _firstNameError,
          onChanged: (_) {
            if (_firstNameError != null) setState(() => _firstNameError = null);
          },
        ),
        const SizedBox(height: 8),
        const OnboardingFieldLabel(label: 'Soyad', required: true),
        CustomTextField(
          controller: _lastNameController,
          hintText: 'Örn. Yılmaz',
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: _lastNameError,
          onChanged: (_) {
            if (_lastNameError != null) setState(() => _lastNameError = null);
          },
        ),
        const SizedBox(height: 8),
        const OnboardingFieldLabel(label: 'E-posta', required: true),
        CustomTextField(
          controller: _emailController,
          hintText: 'ornek@email.com',
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
        const SizedBox(height: 8),
        const OnboardingFieldLabel(label: 'Telefon (isteğe bağlı)'),
        IntlPhoneField(
          decoration: CustomTextField.themedDecoration(
            context,
            hintText: '5XX XXX XX XX',
            errorText: _phoneError,
          ),
          initialCountryCode: 'TR',
          disableLengthCheck: true,
          onChanged: (phone) {
            _phoneNumber = phone.completeNumber;
            if (_phoneError != null) setState(() => _phoneError = null);
          },
        ),
        const SizedBox(height: 8),
        AuthPasswordField(
          controller: _passwordController,
          errorText: _passwordError,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        const SizedBox(height: 8),
        AuthPasswordField(
          controller: _confirmPasswordController,
          label: 'Şifre tekrar',
          hintText: 'Şifrenizi tekrar girin',
          errorText: _confirmPasswordError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          onChanged: (_) {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
          },
        ),
        const SizedBox(height: 14),
        CustomButton(
          label: 'Hesap oluştur',
          height: 48,
          isLoading: widget.isLoading,
          onPressed: _submit,
          labelStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
