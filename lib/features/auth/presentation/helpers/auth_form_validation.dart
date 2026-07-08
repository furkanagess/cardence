import '../../../../l10n/app_localizations.dart';
import '../../../../core/validation/app_validators.dart';

/// Auth formlarında alan doğrulama hata metinleri (l10n).
abstract final class AuthFormValidation {
  static String? emailError(AppLocalizations l10n, String email) {
    if (!AppValidators.matches(AppValidators.email, email)) {
      return l10n.geerliBirEPostaAdresi;
    }
    return null;
  }

  static String? passwordError(AppLocalizations l10n, String password) {
    if (!AppValidators.isValidPassword(password)) {
      return l10n.sifreEnAzKarakter(AppValidators.minPasswordLength);
    }
    return null;
  }

  static String? phoneLoginError(AppLocalizations l10n, String phone) {
    if (phone.length < 8) {
      return l10n.geerliBirTelefonNumarasGirin;
    }
    return null;
  }

  static String? optionalPhoneError(
    AppLocalizations l10n,
    String? completeNumber,
  ) {
    final phone = completeNumber?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (phone.length > AppValidators.maxPhoneLength) {
      return l10n.telefonNumarasEnFazla20;
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < AppValidators.minPhoneDigits ||
        digits.length > AppValidators.maxPhoneDigits) {
      return l10n.geerliBirTelefonNumarasGirin;
    }
    return null;
  }
}
