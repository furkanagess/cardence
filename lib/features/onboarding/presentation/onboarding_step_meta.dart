import '../../../l10n/app_localizations.dart';
import 'onboarding_step_titles.dart';

/// Onboarding kart oluşturma adımlarının başlık ve alt başlık meta verisi.
class OnboardingStepMeta {
  OnboardingStepMeta._();

  static String title(AppLocalizations l10n, int index) {
    return OnboardingStepTitles.forIndex(l10n, index);
  }

  static String subtitle(AppLocalizations l10n, int index) {
    return switch (index) {
      0 => l10n.kartnzdaGrnecekAdnzGirin,
      1 => l10n.kartnznnYzndeGrnecekBilgiler,
      2 => l10n.profilFotorafnzKartnzdaGrnrsterseniz,
      3 => l10n.iletiimProfilVeKiiselNot,
      4 => l10n.kartnznDijitalKimliinizelletirin,
      _ => '',
    };
  }
}
