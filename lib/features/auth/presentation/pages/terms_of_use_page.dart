import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import 'legal_document_page.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LegalDocumentPage(
      title: l10n.termsOfUseTitle,
      sections: [
        LegalSection(title: l10n.termsSection1Title, body: l10n.termsSection1Body),
        LegalSection(title: l10n.termsSection2Title, body: l10n.termsSection2Body),
        LegalSection(title: l10n.termsSection3Title, body: l10n.termsSection3Body),
        LegalSection(title: l10n.termsSection4Title, body: l10n.termsSection4Body),
        LegalSection(title: l10n.termsSection5Title, body: l10n.termsSection5Body),
        LegalSection(title: l10n.termsSection6Title, body: l10n.termsSection6Body),
        LegalSection(title: l10n.termsSection7Title, body: l10n.termsSection7Body),
      ],
    );
  }
}
