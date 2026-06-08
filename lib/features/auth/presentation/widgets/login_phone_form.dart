import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/validation/app_validators.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import 'auth_password_field.dart';

class LoginPhoneForm extends StatefulWidget {
  const LoginPhoneForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    this.showSubmitButton = true,
    this.reserveForgotPasswordSlot = false,
  });

  final bool isLoading;
  final void Function({required String phone, required String password}) onSubmit;
  final bool showSubmitButton;
  final bool reserveForgotPasswordSlot;

  @override
  State<LoginPhoneForm> createState() => LoginPhoneFormState();
}

class LoginPhoneFormState extends State<LoginPhoneForm> {
  final _passwordController = TextEditingController();
  String _phoneNumber = '';
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void submit() => _submit();

  void _submit() {
    final phone = _phoneNumber.trim();
    final password = _passwordController.text;

    String? phoneError;
    String? passwordError;

    if (phone.length < 8) {
      phoneError = 'Geçerli bir telefon numarası girin.';
    }
    if (!AppValidators.isValidPassword(password)) {
      passwordError =
          'Şifre en az ${AppValidators.minPasswordLength} karakter olmalıdır.';
    }

    setState(() {
      _phoneError = phoneError;
      _passwordError = passwordError;
    });

    if (phoneError != null || passwordError != null) return;

    widget.onSubmit(phone: phone, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const OnboardingFieldLabel(label: 'Telefon', required: true),
        IntlPhoneField(
          decoration: CustomTextField.themedDecoration(
            context,
            hintText: '5XX XXX XX XX',
            errorText: _phoneError,
          ),
          initialCountryCode: 'TR',
          disableLengthCheck: false,
          onChanged: (phone) {
            _phoneNumber = phone.completeNumber;
            if (_phoneError != null) setState(() => _phoneError = null);
          },
        ),
        const SizedBox(height: 10),
        AuthPasswordField(
          controller: _passwordController,
          errorText: _passwordError,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          onChanged: (_) {
            if (_passwordError != null) setState(() => _passwordError = null);
          },
        ),
        if (widget.reserveForgotPasswordSlot) const SizedBox(height: 54),
        if (widget.showSubmitButton) ...[
          const SizedBox(height: 16),
          CustomButton(
            label: 'Giriş yap',
            height: 48,
            isLoading: widget.isLoading,
            onPressed: _submit,
            labelStyle: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}
