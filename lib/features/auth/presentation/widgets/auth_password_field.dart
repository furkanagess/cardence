import 'package:flutter/material.dart';

import '../../../../core/widgets/atoms/custom_text_field.dart';
import '../../../onboarding/presentation/widgets/onboarding_step_shell.dart';

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    super.key,
    required this.controller,
    this.label = 'Şifre',
    this.hintText = 'En az 8 karakter',
    this.errorText,
    this.textInputAction = TextInputAction.done,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final String? errorText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OnboardingFieldLabel(label: widget.label, required: true),
        CustomTextField(
          controller: widget.controller,
          hintText: widget.hintText,
          obscureText: _obscure,
          textInputAction: widget.textInputAction,
          autocorrect: false,
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          errorText: widget.errorText,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
        ),
      ],
    );
  }
}
