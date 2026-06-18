import 'package:flutter/material.dart';

import 'legal_document_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _sections = [
    LegalSection(
      title: '1. Toplanan veriler',
      body:
          'Hesap oluştururken ad soyad, e-posta ve isteğe bağlı telefon numaranızı '
          'toplarız. Kartvizit bilgileriniz ve uygulama kullanımınıza ilişkin '
          'teknik veriler hizmetin sunulması için işlenir.',
    ),
    LegalSection(
      title: '2. Verilerin kullanımı',
      body: 'Verileriniz hesabınızı yönetmek, kartvizitlerinizi paylaşmak, '
          'güvenliği sağlamak ve hizmeti iyileştirmek amacıyla kullanılır. '
          'Pazarlama iletişimi yalnızca açık rızanız varsa gönderilir.',
    ),
    LegalSection(
      title: '3. Veri paylaşımı',
      body:
          'Kişisel verilerinizi üçüncü taraflara satmayız. Yasal zorunluluklar, '
          'hizmet sağlayıcıları (barındırma, analitik) ve açık rızanız kapsamında '
          'sınırlı paylaşım yapılabilir.',
    ),
    LegalSection(
      title: '4. Saklama süresi',
      body: 'Hesabınız aktif olduğu sürece verileriniz saklanır. Hesabınızı '
          'sildiğinizde, yasal yükümlülükler dışında verileriniz makul süre '
          'içinde silinir veya anonimleştirilir.',
    ),
    LegalSection(
      title: '5. Haklarınız',
      body: 'KVKK kapsamında verilerinize erişme, düzeltme, silme ve işlemeyi '
          'kısıtlama haklarına sahipsiniz. Taleplerinizi Destek bölümünden '
          'iletebilirsiniz.',
    ),
    LegalSection(
      title: '6. Güvenlik',
      body: 'Verilerinizi korumak için şifreleme, erişim kontrolü ve düzenli '
          'güvenlik değerlendirmeleri uygularız. Hiçbir sistem %100 güvenli '
          'değildir; güçlü bir şifre kullanmanızı öneririz.',
    ),
    LegalSection(
      title: '7. Politika güncellemeleri',
      body: 'Bu politikayı zaman zaman güncelleyebiliriz. Önemli değişiklikler '
          'uygulama içinden bildirilir. Güncellemeden sonra hizmeti kullanmaya '
          'devam etmeniz yeni politikayı kabul ettiğiniz anlamına gelir.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentPage(
      title: 'Gizlilik Politikası',
      sections: _sections,
    );
  }
}
