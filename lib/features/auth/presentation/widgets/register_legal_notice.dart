import 'package:flutter/gestures.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';

import '../pages/privacy_policy_page.dart';
import '../pages/terms_of_use_page.dart';

class RegisterLegalNotice extends StatefulWidget {
  const RegisterLegalNotice({super.key});

  @override
  State<RegisterLegalNotice> createState() => _RegisterLegalNoticeState();
}

class _RegisterLegalNoticeState extends State<RegisterLegalNotice> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _openTermsOfUse(context);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _openPrivacyPolicy(context);
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  void _openTermsOfUse(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const TermsOfUsePage(),
      ),
    );
  }

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const PrivacyPolicyPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = textTheme.labelSmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final linkStyle = baseStyle?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w700,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: 'Kayıt olarak '),
          TextSpan(
            text: context.l10n.kullanmKoullar,
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          const TextSpan(text: ' ve '),
          TextSpan(
            text: context.l10n.gizlilikPolitikas,
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          const TextSpan(text: '\'nı kabul etmiş sayılırsınız.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
