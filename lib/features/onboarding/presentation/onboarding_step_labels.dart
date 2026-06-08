/// Onboarding adım etiketleri (ilerleme başlığı).
class OnboardingStepLabels {
  OnboardingStepLabels._();

  static const List<String> all = [
    'Başlangıç',
    'Kimlik',
    'İş bilgileri',
    'İletişim',
    'Ek bilgiler',
    'Önizleme',
  ];

  static String forIndex(int index) {
    if (index < 0 || index >= all.length) return '';
    return all[index];
  }
}
