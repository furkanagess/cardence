import 'package:flutter/material.dart';

import '../../../../core/validation/app_validators.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import 'auth_password_field.dart';

class LoginEmailForm extends StatefulWidget {
  const LoginEmailForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
    this.onForgotPassword,
    this.showSubmitButton = true,
    this.showForgotPasswordLink = true,
  });

  final bool isLoading;
  final void Function({required String email, required String password})
      onSubmit;
  final VoidCallback? onForgotPassword;
  final bool showSubmitButton;
  final bool showForgotPasswordLink;

  @override
  State<LoginEmailForm> createState() => LoginEmailFormState();
}

class LoginEmailFormState extends State<LoginEmailForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void submit() => _submit();

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailError;
    String? passwordError;

    if (!AppValidators.matches(AppValidators.email, email)) {
      emailError = 'Geçerli bir e-posta girin.';
    }
    if (!AppValidators.isValidPassword(password)) {
      passwordError =
          'Şifre en az ${AppValidators.minPasswordLength} karakter olmalıdır.';
    }

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) return;

    widget.onSubmit(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
        if (widget.showForgotPasswordLink &&
            widget.onForgotPassword != null) ...[
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: widget.isLoading ? null : widget.onForgotPassword,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Şifremi unuttum'),
            ),
          ),
        ],
        if (widget.showSubmitButton) ...[
          const SizedBox(height: 16),
          CustomButton(
            label: 'Giriş yap',
            height: 48,
            isLoading: widget.isLoading,
            onPressed: _submit,
            labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ],
    );
  }
}
