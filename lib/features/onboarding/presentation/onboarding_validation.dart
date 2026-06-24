import '../../../l10n/app_localizations.dart';
import '../../../core/validation/app_validators.dart';
import 'onboarding_name_helper.dart';

/// Onboarding adımlarında zorunlu alan doğrulaması.
class OnboardingValidation {
  OnboardingValidation._();

  static String? validateFirstName(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.adZorunludur;
    if (!AppValidators.matches(AppValidators.personName, trimmed)) {
      return l10n.adYalnzcaHarfIermeliEn;
    }
    return null;
  }

  static String? validateLastName(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.soyadZorunludur;
    if (!AppValidators.matches(AppValidators.personName, trimmed)) {
      return l10n.soyadYalnzcaHarfIermeliEn;
    }
    return null;
  }

  static String? validateDisplayName(AppLocalizations l10n, String? value) {
    final parts = OnboardingNameHelper.split(value);
    return validateFirstName(l10n, parts.first) ??
        validateLastName(l10n, parts.last);
  }

  static String? validateCompany(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.irketZorunludur;
    if (!AppValidators.matches(AppValidators.organizationText, trimmed)) {
      return l10n.geerliBirirketAdGirin;
    }
    return null;
  }

  static String? validateTitle(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.pozisyonZorunludur;
    if (!AppValidators.matches(AppValidators.organizationText, trimmed)) {
      return l10n.geerliBirPozisyonGirin;
    }
    return null;
  }

  static String? validateEmail(AppLocalizations l10n, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.ePostaZorunludur;
    if (!AppValidators.matches(AppValidators.email, trimmed)) {
      return l10n.geerliBirEPostaAdresi;
    }
    return null;
  }

  static bool hasRequiredFields(
    AppLocalizations l10n, {
    required String? displayName,
    required String? company,
    required String? title,
    required String? email,
  }) {
    return fieldsAreValid(
      displayName: displayName,
      company: company,
      title: title,
      email: email,
    );
  }

  /// Cubit/state katmanı için mesaj üretmeden doğrulama.
  static bool fieldsAreValid({
    required String? displayName,
    required String? company,
    required String? title,
    required String? email,
  }) {
    final parts = OnboardingNameHelper.split(displayName);
    if (!AppValidators.matches(AppValidators.personName, parts.first)) {
      return false;
    }
    if (!AppValidators.matches(AppValidators.personName, parts.last)) {
      return false;
    }
    if (!AppValidators.matches(AppValidators.organizationText, company)) {
      return false;
    }
    if (!AppValidators.matches(AppValidators.organizationText, title)) {
      return false;
    }
    if (!AppValidators.matches(AppValidators.email, email)) {
      return false;
    }
    return true;
  }
}
