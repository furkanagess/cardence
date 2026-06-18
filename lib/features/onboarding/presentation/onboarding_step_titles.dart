/// Onboarding adım başlıkları (AppBar).
class OnboardingStepTitles {
  OnboardingStepTitles._();

  static const List<String> _titles = [
    'Adınız',
    'İş bilgileri',
    'Profil fotoğrafı',
    'Ek bilgiler',
    'Kart önizlemesi',
  ];

  static String forIndex(int index) {
    if (index < 0 || index >= _titles.length) return '';
    return _titles[index];
  }

  static bool showsOptionalBadge(int index) => index == 2 || index == 3;
}
