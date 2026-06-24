import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import 'legal_document_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LegalDocumentPage(
      title: l10n.privacyPolicyTitle,
      sections: [
        LegalSection(title: l10n.privacySection1Title, body: l10n.privacySection1Body),
        LegalSection(title: l10n.privacySection2Title, body: l10n.privacySection2Body),
        LegalSection(title: l10n.privacySection3Title, body: l10n.privacySection3Body),
        LegalSection(title: l10n.privacySection4Title, body: l10n.privacySection4Body),
        LegalSection(title: l10n.privacySection5Title, body: l10n.privacySection5Body),
        LegalSection(title: l10n.privacySection6Title, body: l10n.privacySection6Body),
        LegalSection(title: l10n.privacySection7Title, body: l10n.privacySection7Body),
      ],
    );
  }
}
