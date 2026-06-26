import '../../../../l10n/app_localizations.dart';
import '../../domain/helpers/saved_card_field_catalog.dart';

/// Kayıtlı kart alan etiketleri ve ipuçları — presentation katmanı l10n.
class SavedCardFieldL10n {
  const SavedCardFieldL10n._();

  static String label(AppLocalizations l10n, SavedCardFieldKey key) {
    return switch (key) {
      SavedCardFieldKey.displayName => l10n.adSoyad,
      SavedCardFieldKey.email => l10n.ePosta,
      SavedCardFieldKey.phone => l10n.telefon,
      SavedCardFieldKey.company => l10n.irket,
      SavedCardFieldKey.title => l10n.nvlan,
      SavedCardFieldKey.website => l10n.webSitesi,
      SavedCardFieldKey.linkedin => l10n.linkedin,
      SavedCardFieldKey.school => l10n.okul,
      SavedCardFieldKey.about => l10n.hakkmda,
      SavedCardFieldKey.skills => l10n.yetenekler,
      SavedCardFieldKey.address => l10n.adres,
      SavedCardFieldKey.city => l10n.ehir,
      SavedCardFieldKey.country => l10n.lke,
      SavedCardFieldKey.department => l10n.departman,
      SavedCardFieldKey.attendedEvents => l10n.katldEtkinlikler,
      SavedCardFieldKey.twitter => l10n.twitterX,
      SavedCardFieldKey.instagram => l10n.instagram,
      SavedCardFieldKey.birthday => l10n.doumGn,
    };
  }

  static String hint(AppLocalizations l10n, SavedCardFieldKey key) {
    return switch (key) {
      SavedCardFieldKey.displayName => l10n.savedCardFieldHintDisplayName,
      SavedCardFieldKey.email => l10n.savedCardFieldHintEmail,
      SavedCardFieldKey.phone => l10n.savedCardFieldHintPhone,
      SavedCardFieldKey.company => l10n.savedCardFieldHintCompany,
      SavedCardFieldKey.title => l10n.savedCardFieldHintTitle,
      SavedCardFieldKey.website => l10n.savedCardFieldHintWebsite,
      SavedCardFieldKey.linkedin => l10n.savedCardFieldHintLinkedin,
      SavedCardFieldKey.school => l10n.savedCardFieldHintSchool,
      SavedCardFieldKey.about => l10n.savedCardFieldHintAbout,
      SavedCardFieldKey.skills => l10n.savedCardFieldHintSkills,
      SavedCardFieldKey.address => l10n.savedCardFieldHintAddress,
      SavedCardFieldKey.city => l10n.savedCardFieldHintCity,
      SavedCardFieldKey.country => l10n.savedCardFieldHintCountry,
      SavedCardFieldKey.department => l10n.savedCardFieldHintDepartment,
      SavedCardFieldKey.attendedEvents => l10n.savedCardFieldHintAttendedEvents,
      SavedCardFieldKey.twitter => l10n.savedCardFieldHintTwitter,
      SavedCardFieldKey.instagram => l10n.savedCardFieldHintInstagram,
      SavedCardFieldKey.birthday => l10n.savedCardFieldHintBirthday,
    };
  }
}
