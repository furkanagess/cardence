import 'package:flutter/material.dart';

import 'legal_document_page.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  static const _sections = [
    LegalSection(
      title: '1. Hizmetin kapsamı',
      body:
          'Cardence; dijital kartvizit oluşturma, paylaşma ve yönetme hizmeti sunar. '
          'Uygulamayı kullanarak bu koşulları kabul etmiş sayılırsınız.',
    ),
    LegalSection(
      title: '2. Hesap oluşturma',
      body:
          'Kayıt sırasında verdiğiniz bilgilerin doğru ve güncel olması sizin '
          'sorumluluğunuzdadır. Hesap güvenliğinizi korumak için şifrenizi '
          'üçüncü kişilerle paylaşmamalısınız.',
    ),
    LegalSection(
      title: '3. Kabul edilebilir kullanım',
      body:
          'Hizmeti yasa dışı, yanıltıcı veya başkalarının haklarını ihlal edecek '
          'şekilde kullanamazsınız. Kartvizit içeriklerinden yalnızca siz '
          'sorumlusunuz.',
    ),
    LegalSection(
      title: '4. Fikri mülkiyet',
      body: 'Cardence markası, arayüzü ve yazılımı Cardence\'e aittir. '
          'Oluşturduğunuz kartvizit içeriklerinin hakları size aittir; '
          'hizmeti sunmak için gerekli sınırlı kullanım lisansı vermiş olursunuz.',
    ),
    LegalSection(
      title: '5. Hizmet değişiklikleri',
      body: 'Özellikleri geliştirmek veya yasal yükümlülükleri karşılamak için '
          'hizmette değişiklik yapabiliriz. Önemli güncellemeler uygulama '
          'içinden veya e-posta yoluyla bildirilebilir.',
    ),
    LegalSection(
      title: '6. Sorumluluk sınırı',
      body:
          'Hizmet "olduğu gibi" sunulur. Makul özeni gösteririz; ancak kesintisiz '
          'veya hatasız çalışma garantisi verilmez. Yasal olarak izin verilen '
          'ölçüde dolaylı zararlardan sorumlu tutulamayız.',
    ),
    LegalSection(
      title: '7. İletişim',
      body: 'Kullanım koşulları hakkında sorularınız için uygulama içindeki '
          'Destek bölümünden bize ulaşabilirsiniz.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentPage(
      title: 'Kullanım Koşulları',
      sections: _sections,
    );
  }
}
