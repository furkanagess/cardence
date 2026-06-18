/// Manuel kart ekleme adım başlıkları (AppBar).
class AddManualCardStepTitles {
  AddManualCardStepTitles._();

  static const List<String> _titles = [
    'Ad Soyad',
    'İş bilgileri',
    'Ek bilgiler',
    'Kart önizlemesi',
  ];

  static String forIndex(int index) {
    if (index < 0 || index >= _titles.length) return '';
    return _titles[index];
  }

  static bool showsOptionalBadge(int index) => false;
}
