/// Onboarding tek bir sayfanın içeriği (domain entity – framework yok).
class OnboardingPage {
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.iconCodePoint,
  });

  final String title;
  final String description;
  final int iconCodePoint;
}
