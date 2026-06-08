import '../../../core/validation/app_validators.dart';
import 'onboarding_name_helper.dart';

/// Onboarding adımlarında zorunlu alan doğrulaması.
class OnboardingValidation {
  OnboardingValidation._();

  static String? validateFirstName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Ad zorunludur';
    if (!AppValidators.matches(AppValidators.personName, trimmed)) {
      return 'Ad yalnızca harf içermeli (en az 2 karakter)';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Soyad zorunludur';
    if (!AppValidators.matches(AppValidators.personName, trimmed)) {
      return 'Soyad yalnızca harf içermeli (en az 2 karakter)';
    }
    return null;
  }

  static String? validateDisplayName(String? value) {
    final parts = OnboardingNameHelper.split(value);
    return validateFirstName(parts.first) ?? validateLastName(parts.last);
  }

  static String? validateCompany(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Şirket zorunludur';
    if (!AppValidators.matches(AppValidators.organizationText, trimmed)) {
      return 'Geçerli bir şirket adı girin';
    }
    return null;
  }

  static String? validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Pozisyon zorunludur';
    if (!AppValidators.matches(AppValidators.organizationText, trimmed)) {
      return 'Geçerli bir pozisyon girin';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'E-posta zorunludur';
    if (!AppValidators.matches(AppValidators.email, trimmed)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  static bool hasRequiredFields({
    required String? displayName,
    required String? company,
    required String? title,
    required String? email,
  }) {
    return validateDisplayName(displayName) == null &&
        validateCompany(company) == null &&
        validateTitle(title) == null &&
        validateEmail(email) == null;
  }
}
