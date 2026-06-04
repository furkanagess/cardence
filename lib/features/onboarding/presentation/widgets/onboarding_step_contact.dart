import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../domain/entities/onboarding_card_draft.dart';

class OnboardingStepContact extends StatefulWidget {
  const OnboardingStepContact({
    super.key,
    required this.draft,
    required this.onChanged,
  });

  final OnboardingCardDraft draft;
  final ValueChanged<OnboardingCardDraft> onChanged;

  @override
  State<OnboardingStepContact> createState() => _OnboardingStepContactState();
}

class _OnboardingStepContactState extends State<OnboardingStepContact> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController =
        TextEditingController(text: widget.draft.email ?? '');
  }

  @override
  void didUpdateWidget(OnboardingStepContact oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.draft.email != widget.draft.email &&
        _emailController.text != (widget.draft.email ?? '')) {
      _emailController.text = widget.draft.email ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
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
    if (digits.startsWith('90') && digits.length > 2) return digits.substring(2);
    if (digits.startsWith('1') && digits.length > 1) return digits.substring(1);
    if (digits.startsWith('44') && digits.length > 2) return digits.substring(2);
    if (digits.startsWith('49') && digits.length > 2) return digits.substring(2);
    if (digits.startsWith('33') && digits.length > 2) return digits.substring(2);
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'İletişim',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'E-posta ve telefon numaran kartında paylaşılabilsin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          TextField(
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(
              hintText: 'E-posta adresin',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            controller: _emailController,
            onChanged: (value) => widget.onChanged(
              widget.draft.copyWith(email: value.isEmpty ? null : value),
            ),
          ),
          const SizedBox(height: 16),
          IntlPhoneField(
            initialCountryCode: _countryCodeFromPhone(widget.draft.phone),
            initialValue: _nationalFromPhone(widget.draft.phone),
            showCountryFlag: true,
            decoration: const InputDecoration(
              hintText: 'Telefon numaran',
            ),
            onChanged: (phone) => widget.onChanged(
              widget.draft.copyWith(phone: phone.completeNumber),
            ),
          ),
        ],
      ),
    );
  }
}
