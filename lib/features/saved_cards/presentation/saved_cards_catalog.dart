import '../domain/entities/saved_card.dart';

/// Kaydedilen kartlar listesi ve seçici için ortak kart kaynağı.
class SavedCardsCatalog {
  SavedCardsCatalog._();

  /// Geliştirme önizlemesi; kalıcı kayıt yokken Kaydedilen Kartlar sekmesinde gösterilir.
  static const List<SavedCard> demoCards = [
    SavedCard(
      cardId: 'dummy-1',
      displayName: 'Elif Yilmaz',
      email: 'elif.yilmaz@nova.io',
      phone: '+90 532 111 22 33',
      company: 'Nova Teknoloji',
      title: 'Product Designer',
      about: 'Urun odakli calisiyor, tasarim kararlarini iyi dokumante ediyor.',
      savedAt: 1734220800000,
    ),
    SavedCard(
      cardId: 'dummy-2',
      displayName: 'Mert Kaya',
      email: 'mert.kaya@peaklabs.dev',
      phone: '+90 533 444 55 66',
      company: 'Peak Labs',
      title: 'Mobile Engineer',
      savedAt: 1734998400000,
    ),
    SavedCard(
      cardId: 'dummy-3',
      displayName: 'Zeynep Demir',
      email: 'zeynep.demir@altinmedia.co',
      phone: '+90 534 777 88 99',
      company: 'Altin Media',
      title: 'Growth Manager',
      about: 'Kampanya analitigi iyi, is birligine acik ve planli ilerliyor.',
      savedAt: 1735689600000,
    ),
    SavedCard(
      cardId: 'dummy-4',
      displayName: 'Kerem Arslan',
      email: 'kerem.arslan@byteforge.ai',
      phone: '+90 535 123 45 67',
      company: 'ByteForge AI',
      title: 'AI Consultant',
      about: 'Teknik sunumlari net, AI strateji tarafinda deneyimli.',
      savedAt: 1736294400000,
    ),
    SavedCard(
      cardId: 'dummy-5',
      displayName: 'Derya Acar',
      email: 'derya.acar@orbitstudio.com',
      phone: '+90 536 890 12 34',
      company: 'Orbit Studio',
      title: 'Art Director',
      savedAt: 1736899200000,
    ),
    SavedCard(
      cardId: 'dummy-6',
      displayName: 'Can Ozturk',
      email: 'can.ozturk@northhub.io',
      phone: '+90 537 201 34 56',
      company: 'NorthHub',
      title: 'Sales Lead',
      about: 'Muzakere becerisi yuksek, toplantilarda yonlendirici rol aliyor.',
      savedAt: 1737504000000,
    ),
    SavedCard(
      cardId: 'dummy-7',
      displayName: 'Selin Erdem',
      email: 'selin.erdem@lumina.app',
      phone: '+90 538 778 91 22',
      company: 'Lumina',
      title: 'Marketing Specialist',
      about: 'Icerik ve sosyal medya tarafinda duzenli ve yaratıcı calisiyor.',
      savedAt: 1738108800000,
    ),
    SavedCard(
      cardId: 'dummy-8',
      displayName: 'Burak Cetin',
      email: 'burak.cetin@craftbit.dev',
      phone: '+90 539 654 32 10',
      company: 'CraftBit',
      title: 'Frontend Developer',
      savedAt: 1738713600000,
    ),
    SavedCard(
      cardId: 'dummy-9',
      displayName: 'Naz Karaca',
      email: 'naz.karaca@greenwave.co',
      phone: '+90 530 145 78 90',
      company: 'GreenWave',
      title: 'HR Manager',
      about: 'Iletisimi guclu, ekip kulturune hizli adapte oluyor.',
      savedAt: 1739318400000,
    ),
    SavedCard(
      cardId: 'dummy-10',
      displayName: 'Onur Sari',
      email: 'onur.sari@veritron.ai',
      phone: '+90 531 320 44 55',
      company: 'Veritron AI',
      title: 'Data Scientist',
      about: 'Veri modelleme tarafinda guvenilir, teknik raporlamasi kuvvetli.',
      savedAt: 1739923200000,
    ),
    SavedCard(
      cardId: 'dummy-11',
      displayName: 'Aylin Koc',
      email: 'aylin.koc@skybridge.co',
      phone: '+90 532 908 17 44',
      company: 'SkyBridge',
      title: 'UX Researcher',
      website: 'https://aylinkoc.design',
      school: 'ODTU',
      about: 'Kullanici testlerini duzenli yurutuyor, bulgulari net aktariyor.',
      savedAt: 1740528000000,
    ),
    SavedCard(
      cardId: 'dummy-12',
      displayName: 'Emre Tas',
      email: 'emre.tas@finexa.com',
      phone: '+90 533 210 88 31',
      company: 'Finexa',
      title: 'Finans Analisti',
      linkedin: 'https://linkedin.com/in/emretas',
      savedAt: 1741132800000,
    ),
    SavedCard(
      cardId: 'dummy-13',
      displayName: 'Gizem Polat',
      email: 'gizem.polat@healtech.io',
      phone: '+90 534 667 29 05',
      company: 'HealTech',
      title: 'Product Manager',
      skills: 'Agile, Roadmap, Stakeholder',
      about: 'Sprint planlamasi guclu, ekipler arasi koordinasyonu iyi yonetiyor.',
      savedAt: 1741737600000,
    ),
    SavedCard(
      cardId: 'dummy-14',
      displayName: 'Baris Guney',
      email: 'baris.guney@logistream.net',
      phone: '+90 535 441 70 18',
      company: 'LogiStream',
      title: 'Operations Manager',
      website: 'https://logistream.net',
      savedAt: 1742342400000,
    ),
    SavedCard(
      cardId: 'dummy-15',
      displayName: 'Ceren Aydin',
      email: 'ceren.aydin@pixelwave.studio',
      phone: '+90 536 552 93 27',
      company: 'PixelWave Studio',
      title: 'Motion Designer',
      linkedin: 'https://linkedin.com/in/cerenaydin',
      school: 'Mimar Sinan GSU',
      about: 'Animasyon teslimleri zamaninda, marka diline uyumlu calisiyor.',
      savedAt: 1742947200000,
    ),
    SavedCard(
      cardId: 'dummy-16',
      displayName: 'Kaan Yildiz',
      email: 'kaan.yildiz@cloudnest.dev',
      phone: '+90 537 118 64 90',
      company: 'CloudNest',
      title: 'DevOps Engineer',
      skills: 'Kubernetes, CI/CD, Terraform',
      savedAt: 1743552000000,
    ),
    SavedCard(
      cardId: 'dummy-17',
      displayName: 'Melis Ucar',
      email: 'melis.ucar@brandloom.agency',
      phone: '+90 538 309 55 72',
      company: 'Brandloom',
      title: 'Brand Strategist',
      website: 'https://brandloom.agency',
      about: 'Marka konumlandirmada net oneriler sunuyor, sunumlari ikna edici.',
      savedAt: 1744156800000,
    ),
    SavedCard(
      cardId: 'dummy-18',
      displayName: 'Tolga Seker',
      email: 'tolga.seker@autoparts.tr',
      phone: '+90 539 874 20 66',
      company: 'AutoParts TR',
      title: 'Supply Chain Lead',
      savedAt: 1744761600000,
    ),
    SavedCard(
      cardId: 'dummy-19',
      displayName: 'Irem Balci',
      email: 'irem.balci@edunova.org',
      phone: '+90 530 246 81 39',
      company: 'EduNova',
      title: 'Learning Designer',
      linkedin: 'https://linkedin.com/in/irembalci',
      school: 'Bogazici Universitesi',
      skills: 'E-ogrenme, Storyboard, LMS',
      about: 'Egitim iceriklerini ogrenci odakli kurguluyor, geri bildirime acik.',
      savedAt: 1745366400000,
    ),
    SavedCard(
      cardId: 'dummy-20',
      displayName: 'Serkan Mutlu',
      email: 'serkan.mutlu@cybershield.io',
      phone: '+90 531 703 12 58',
      company: 'CyberShield',
      title: 'Security Architect',
      website: 'https://cybershield.io',
      linkedin: 'https://linkedin.com/in/serkanmutlu',
      about: 'Guvenlik denetimlerinde detayci, risk raporlarini anlasilir yaziyor.',
      savedAt: 1745971200000,
    ),
  ];

  static bool _isDummyCardId(String cardId) => cardId.startsWith('dummy-');

  /// Yalnızca yerel demo kartları gösterilirken true (boş cüzdan demo değildir).
  static bool isUsingDemoCards(List<SavedCard> persisted) {
    if (persisted.isEmpty) return false;
    return persisted.every((c) => _isDummyCardId(c.cardId));
  }

  /// Katalogdaki tüm demo kartlar; kalıcı sıra korunur, yeni dummy'ler eklenir.
  static List<SavedCard> demoDisplayList(List<SavedCard> persisted) {
    final catalogById = {for (final c in demoCards) c.cardId: c};
    if (persisted.isEmpty) {
      return List<SavedCard>.from(demoCards);
    }

    final ordered = <SavedCard>[];
    final seen = <String>{};
    for (final card in persisted) {
      if (!_isDummyCardId(card.cardId)) continue;
      final fromCatalog = catalogById[card.cardId];
      if (fromCatalog == null) continue;
      ordered.add(fromCatalog);
      seen.add(card.cardId);
    }
    for (final card in demoCards) {
      if (!seen.contains(card.cardId)) ordered.add(card);
    }
    return ordered;
  }

  /// Kalıcı kayıtlar varsa onları, demo modunda güncel katalog listesini döndürür.
  static List<SavedCard> displayCards(List<SavedCard> persisted) {
    if (isUsingDemoCards(persisted)) {
      return demoDisplayList(persisted);
    }
    return persisted;
  }
}
