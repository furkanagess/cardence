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
  ];

  /// Kalıcı kayıtlar varsa onları, yoksa demo kartları döndürür.
  static List<SavedCard> displayCards(List<SavedCard> persisted) {
    if (persisted.isNotEmpty) return persisted;
    return List<SavedCard>.from(demoCards);
  }

  static bool isUsingDemoCards(List<SavedCard> persisted) => persisted.isEmpty;
}
