import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/validation/app_validators.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../onboarding/presentation/widgets/onboarding_step_shell.dart';
import 'auth_password_field.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({
    super.key,
    required this.isLoading,
    required this.isOtpStep,
    required this.pendingEmail,
    required this.onRequestOtp,
    required this.onResetPassword,
    required this.onBack,
    this.initialEmail,
  });

  final bool isLoading;
  final bool isOtpStep;
  final String? pendingEmail;
  final String? initialEmail;
  final ValueChanged<String> onRequestOtp;
  final void Function({
    required String email,
    required String otpCode,
    required String newPassword,
  }) onResetPassword;
  final VoidCallback onBack;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _emailError;
  String? _otpError;
  String? _passwordError;
  String? _confirmError;

  @override
  void initState() {
    super.initState();
    final email = widget.initialEmail?.trim();
    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _requestOtp() {
    final email = _emailController.text.trim();
    if (!AppValidators.matches(AppValidators.email, email)) {
      setState(() => _emailError = 'Geçerli bir e-posta girin.');
      return;
    }
    setState(() => _emailError = null);
    widget.onRequestOtp(email);
  }

  void _resetPassword() {
    final email = widget.pendingEmail ?? _emailController.text.trim();
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    String? otpError;
    String? passwordError;
    String? confirmError;

    if (otp.length < 4) otpError = 'Doğrulama kodunu girin.';
    if (!AppValidators.isValidPassword(password)) {
      passwordError =
          'Şifre en az ${AppValidators.minPasswordLength} karakter olmalıdır.';
    }
    if (password != confirm) confirmError = 'Şifreler eşleşmiyor.';

    setState(() {
      _otpError = otpError;
      _passwordError = passwordError;
      _confirmError = confirmError;
    });

    if (otpError != null || passwordError != null || confirmError != null) {
      return;
    }

    widget.onResetPassword(
      email: email,
      otpCode: otp,
      newPassword: password,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (widget.isOtpStep) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.kodGnderildi,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            widget.pendingEmail ?? '',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          OnboardingFieldLabel(label: context.l10n.dorulamaKodu, required: true),
          CustomTextField(
            controller: _otpController,
            hintText: context.l10n.msg6HaneliKod,
            keyboardType: TextInputType.number,
            maxLength: 6,
            errorText: _otpError,
            onChanged: (_) {
              if (_otpError != null) setState(() => _otpError = null);
            },
          ),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: _passwordController,
            label: context.l10n.yeniifre,
            errorText: _passwordError,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_passwordError != null) setState(() => _passwordError = null);
            },
          ),
          const SizedBox(height: 8),
          AuthPasswordField(
            controller: _confirmController,
            label: context.l10n.yeniifreTekrar,
            hintText: context.l10n.ifreniziTekrarGirin,
            errorText: _confirmError,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _resetPassword(),
            onChanged: (_) {
              if (_confirmError != null) setState(() => _confirmError = null);
            },
          ),
          const SizedBox(height: 14),
          CustomButton(
            label: context.l10n.ifreyiGncelle,
            height: 48,
            isLoading: widget.isLoading,
            onPressed: _resetPassword,
          ),
          const SizedBox(height: 8),
          CustomButton.tonal(
            label: context.l10n.geri,
            height: 40,
            enabled: !widget.isLoading,
            onPressed: widget.onBack,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingFieldLabel(label: context.l10n.ePosta, required: true),
        CustomTextField(
          controller: _emailController,
          hintText: context.l10n.ornekEmailCom,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          errorText: _emailError,
          onSubmitted: (_) => _requestOtp(),
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.kaytlEPostaAdresinizeSfrlama,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        CustomButton(
          label: context.l10n.kodGnder,
          height: 48,
          isLoading: widget.isLoading,
          onPressed: _requestOtp,
        ),
      ],
    );
  }
}
