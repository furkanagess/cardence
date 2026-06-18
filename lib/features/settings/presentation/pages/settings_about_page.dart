import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/pages/legal_document_page.dart';

class SettingsAboutPage extends StatelessWidget {
  const SettingsAboutPage({super.key});

  static const _sections = [
    LegalSection(
      title: AppConstants.appName,
      body:
          '${AppConstants.appTagline}\n\n'
          'Cardence ile dijital kartvizitlerinizi oluşturabilir, paylaşabilir '
          've cüzdanınızda yönetebilirsiniz.',
    ),
    LegalSection(
      title: 'Sürüm',
      body: 'Uygulama sürümü: ${AppConstants.appVersion}',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentPage(
      title: 'Hakkında',
      sections: _sections,
    );
  }
}
