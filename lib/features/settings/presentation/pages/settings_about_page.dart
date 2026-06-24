import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../auth/presentation/pages/legal_document_page.dart';

class SettingsAboutPage extends StatelessWidget {
  const SettingsAboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LegalDocumentPage(
      title: l10n.hakknda,
      sections: [
        LegalSection(
          title: AppConstants.appName,
          body:
              '${AppConstants.appTagline}\n\n'
              '${l10n.cardenceIleDijitalKartvizitlerinizi}',
        ),
        LegalSection(
          title: l10n.srm,
          body: '${l10n.uygulamaSrme} ${AppConstants.appVersion}',
        ),
      ],
    );
  }
}
