import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n_extensions.dart';

import '../../../../core/validation/app_validators.dart';
import '../../../../core/widgets/atoms/custom_button.dart';
import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../onboarding/presentation/widgets/onboarding_step_shell.dart';

class ForgotPasswordForm extends StatefulWidget {
  const ForgotPasswordForm({
    super.key,
    required this.isLoading,
    required this.isLinkSentStep,
    required this.pendingEmail,
    required this.onRequestLink,
    required this.onBackToEmail,
    required this.onBack,
    this.initialEmail,
  });

  final bool isLoading;
  final bool isLinkSentStep;
  final String? pendingEmail;
  final String? initialEmail;
  final ValueChanged<String> onRequestLink;
  final VoidCallback onBackToEmail;
  final VoidCallback onBack;

  @override
  State<ForgotPasswordForm> createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _emailController = TextEditingController();
  String? _emailError;

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
    super.dispose();
  }

  void _requestLink() {
    final email = _emailController.text.trim();
    if (!AppValidators.matches(AppValidators.email, email)) {
      setState(() => _emailError = 'Geçerli bir e-posta girin.');
      return;
    }
    setState(() => _emailError = null);
    widget.onRequestLink(email);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (widget.isLinkSentStep) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 48,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.sifreSifirlamaBaglantisiGonderildi,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.ePostaKutunuzuKontrolEdin,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (widget.pendingEmail != null) ...[
            const SizedBox(height: 12),
            Text(
              widget.pendingEmail!,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          CustomButton.tonal(
            label: context.l10n.geri,
            height: 40,
            onPressed: widget.onBackToEmail,
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
          onSubmitted: (_) => _requestLink(),
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
          label: context.l10n.sifreSifirlamaBaglantisiGonder,
          height: 48,
          isLoading: widget.isLoading,
          onPressed: _requestLink,
        ),
      ],
    );
  }
}
