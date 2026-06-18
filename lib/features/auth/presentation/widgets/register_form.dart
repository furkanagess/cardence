import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/validation/app_validators.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
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
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _phoneNumber = '';
  String? _displayNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final displayName = _displayNameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final phone = _phoneNumber.trim();

    String? displayNameError;
    String? emailError;
    String? phoneError;
    String? passwordError;
    if (displayName.length < 3) {
      displayNameError = 'Ad soyad en az 3 karakter olmalıdır.';
    }
    if (!AppValidators.matches(AppValidators.email, email)) {
      emailError = 'Geçerli bir e-posta girin.';
    }
    phoneError = AppValidators.optionalPhoneError(phone);
    if (!AppValidators.isValidPassword(password)) {
      passwordError =
          'Şifre en az ${AppValidators.minPasswordLength} karakter olmalıdır.';
    }

    setState(() {
      _displayNameError = displayNameError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
    });

    if (displayNameError != null ||
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
        const OnboardingFieldLabel(label: 'Ad Soyad', required: true),
        CustomTextField(
          controller: _displayNameController,
          hintText: 'Adınızı ve soyadınızı girin',
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          prefixIcon: Icon(
            Icons.person_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: _displayNameError,
          onChanged: (_) {
            if (_displayNameError != null) {
              setState(() => _displayNameError = null);
            }
          },
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        const OnboardingFieldLabel(label: 'Telefon'),
        IntlPhoneField(
          decoration: CustomTextField.themedDecoration(
            context,
            hintText: '5XX XXX XX XX',
            errorText: _phoneError,
            prefixIcon: Icon(
              Icons.phone_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          initialCountryCode: 'TR',
          invalidNumberMessage: 'Geçerli bir telefon numarası girin.',
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
        const SizedBox(height: 18),
        CustomButton(
          label: 'Kayıt ol',
          height: 48,
          isLoading: widget.isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }
}
