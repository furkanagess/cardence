import '../../l10n/app_localizations.dart';
import '../network/auth_api_exception.dart';
import 'app_error_keys.dart';

/// API ve auth katmanından gelen sabit hata metinlerini localize eder.
class ApiErrorLocalizer {
  ApiErrorLocalizer._();

  static String localize(AppLocalizations l10n, String message) {
    final normalized = message.trim();
    final mapped =
        _map[l10n.localeName]?[normalized] ?? _map['tr']?[normalized];
    if (mapped != null) {
      return _resolve(l10n, mapped);
    }

    if (normalized.startsWith('Sunucu yanıtı okunamadı')) {
      return l10n.serverResponseUnreadable;
    }

    final passwordMatch = RegExp(
      r'^Şifre en az (\d+) karakter olmalıdır\.$',
    ).firstMatch(normalized);
    if (passwordMatch != null) {
      final minLength = int.tryParse(passwordMatch.group(1)!);
      if (minLength != null) {
        return l10n.authPasswordMinLengthError(minLength);
      }
    }

    return message;
  }

  static String localizeException(AppLocalizations l10n, AuthApiException e) {
    final fromCode = _localizeErrorCode(l10n, e.errorCode);
    if (fromCode != null) return fromCode;
    return localize(l10n, e.message);
  }

  static String? _localizeErrorCode(AppLocalizations l10n, String? errorCode) {
    if (errorCode == null || errorCode.isEmpty) return null;
    final mapped = _errorCodeMap[errorCode];
    if (mapped == null) return null;
    return _resolve(l10n, mapped);
  }

  static String _resolve(AppLocalizations l10n, String key) {
    switch (key) {
      case 'sessionNotFoundLogin':
        return l10n.sessionNotFoundLogin;
      case 'sessionNotFound':
        return l10n.sessionNotFound;
      case 'sessionExpired':
        return l10n.sessionExpired;
      case 'operationFailed':
        return l10n.operationFailed;
      case 'sessionInfoUnavailable':
        return l10n.sessionInfoUnavailable;
      case 'invalidSessionResponse':
        return l10n.invalidSessionResponse;
      case 'profileInfoUnavailable':
        return l10n.profileInfoUnavailable;
      case 'invalidProfileResponse':
        return l10n.invalidProfileResponse;
      case 'linkedinLoginFailed':
        return l10n.linkedinLoginFailed;
      case 'profilePhotoUploadFailed':
        return l10n.profilePhotoUploadFailed;
      case 'serverResponseUnreadable':
        return l10n.serverResponseUnreadable;
      case 'cardIdMissing':
        return l10n.cardIdMissing;
      case 'eventGroupsLoadFailed':
        return l10n.eventGroupsLoadFailed;
      case 'eventGroupLoadFailed':
        return l10n.eventGroupLoadFailed;
      case 'eventGroupCreateFailed':
        return l10n.eventGroupCreateFailed;
      case 'eventPhotoUploadFailed':
        return l10n.eventPhotoUploadFailed;
      case 'eventGroupDeleteFailed':
        return l10n.eventGroupDeleteFailed;
      case 'cardsLinkToGroupFailed':
        return l10n.cardsLinkToGroupFailed;
      case 'cardRemoveFromGroupFailed':
        return l10n.cardRemoveFromGroupFailed;
      case 'supportRequestFailed':
        return l10n.supportRequestFailed;
      case 'supportRequestFailedRetry':
        return l10n.supportRequestFailedRetry;
      case 'supportInvalidRequest':
        return l10n.supportInvalidRequest;
      case 'walletQuotaLoadFailed':
        return l10n.walletQuotaLoadFailed;
      case 'cardAddToWalletFailed':
        return l10n.cardAddToWalletFailed;
      case 'cardInfoLoadFailed':
        return l10n.cardInfoLoadFailed;
      case 'invalidCardId':
        return l10n.invalidCardId;
      case 'invalidCardResponse':
        return l10n.invalidCardResponse;
      case 'connectionError':
        return l10n.connectionError;
      case 'invalidResetToken':
        return l10n.sifreSifirlamaBaglantisiGecersiz;
      case 'authEmailRequired':
        return l10n.authEmailRequired;
      case 'authPasswordRequired':
        return l10n.authPasswordRequired;
      case 'authEmailUserNotFound':
        return l10n.authEmailUserNotFound;
      case 'authInvalidEmailPassword':
        return l10n.authInvalidEmailPassword;
      case 'authPhoneRequired':
        return l10n.authPhoneRequired;
      case 'authPhoneUserNotFound':
        return l10n.authPhoneUserNotFound;
      case 'authInvalidPhonePassword':
        return l10n.authInvalidPhonePassword;
      case 'authDisplayNameRequired':
        return l10n.authDisplayNameRequired;
      case 'authDisplayNameMinLength':
        return l10n.authDisplayNameMinLength;
      case 'authInvalidEmailFormat':
        return l10n.authInvalidEmailFormat;
      case 'authInvalidPhoneFormat':
        return l10n.authInvalidPhoneFormat;
      case 'authEmailAlreadyRegistered':
        return l10n.authEmailAlreadyRegistered;
      case 'authPhoneAlreadyRegistered':
        return l10n.authPhoneAlreadyRegistered;
      case 'authLinkedInCodeRequired':
        return l10n.authLinkedInCodeRequired;
      case 'authInvalidRedirectUri':
        return l10n.authInvalidRedirectUri;
      case 'authLinkedInSessionInvalid':
        return l10n.authLinkedInSessionInvalid;
      case 'authLinkedInUserNotFound':
        return l10n.authLinkedInUserNotFound;
      case 'authInvalidOtp':
        return l10n.authInvalidOtp;
      default:
        return key;
    }
  }

  static const Map<String, String> _errorCodeMap = {
    'InvalidOtp': 'authInvalidOtp',
  };

  static const Map<String, Map<String, String>> _map = {
    'tr': _authMessages,
    'en': _authMessages,
  };

  static const Map<String, String> _authMessages = {
    'Oturum bulunamadı. Lütfen tekrar giriş yapın.': 'sessionNotFoundLogin',
    'Oturum bulunamadı.': 'sessionNotFound',
    'Oturum süresi doldu. Lütfen tekrar giriş yapın.': 'sessionExpired',
    'İşlem başarısız.': 'operationFailed',
    'Oturum bilgisi alınamadı.': 'sessionInfoUnavailable',
    'Geçersiz oturum yanıtı.': 'invalidSessionResponse',
    'Profil bilgisi alınamadı.': 'profileInfoUnavailable',
    'Geçersiz profil yanıtı.': 'invalidProfileResponse',
    'LinkedIn ile giriş başarısız.': 'linkedinLoginFailed',
    'Profil fotoğrafı yüklenemedi.': 'profilePhotoUploadFailed',
    'Sunucu yanıtı okunamadı.': 'serverResponseUnreadable',
    'Kart kimliği eksik.': 'cardIdMissing',
    'Etkinlik grupları alınamadı.': 'eventGroupsLoadFailed',
    'Etkinlik grubu alınamadı.': 'eventGroupLoadFailed',
    'Etkinlik grubu oluşturulamadı.': 'eventGroupCreateFailed',
    'Etkinlik fotoğrafı yüklenemedi.': 'eventPhotoUploadFailed',
    'Etkinlik grubu silinemedi.': 'eventGroupDeleteFailed',
    'Kartlar gruba eklenemedi.': 'cardsLinkToGroupFailed',
    'Kart gruptan çıkarılamadı.': 'cardRemoveFromGroupFailed',
    'Destek talebi gönderilemedi.': 'supportRequestFailed',
    'Cüzdan kotası alınamadı.': 'walletQuotaLoadFailed',
    'Kart cüzdana eklenemedi.': 'cardAddToWalletFailed',
    'Kart bilgisi alınamadı.': 'cardInfoLoadFailed',
    'Geçersiz kart kimliği.': 'invalidCardId',
    'Geçersiz kart yanıtı.': 'invalidCardResponse',
    'Bağlantı hatası. Lütfen tekrar deneyin.': 'connectionError',
    'Destek talebi gönderilemedi. Lütfen tekrar deneyin.':
        'supportRequestFailedRetry',
    'Geçerli bir e-posta ve en az 10 karakterlik bir mesaj girin.':
        'supportInvalidRequest',
    'Şifre sıfırlama bağlantısı geçersiz veya süresi dolmuş.':
        'invalidResetToken',
    'E-posta gereklidir.': 'authEmailRequired',
    'Şifre gereklidir.': 'authPasswordRequired',
    'Bu e-posta ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.':
        'authEmailUserNotFound',
    'E-posta veya şifre hatalı.': 'authInvalidEmailPassword',
    'Telefon gereklidir.': 'authPhoneRequired',
    'Bu telefon ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.':
        'authPhoneUserNotFound',
    'Telefon veya şifre hatalı.': 'authInvalidPhonePassword',
    'Ad soyad gereklidir.': 'authDisplayNameRequired',
    'Ad soyad en az 2 karakter olmalıdır.': 'authDisplayNameMinLength',
    'Geçerli bir e-posta girin.': 'authInvalidEmailFormat',
    'Geçerli bir telefon numarası girin.': 'authInvalidPhoneFormat',
    'Bu e-posta adresi başka bir hesapta kayıtlı.':
        'authEmailAlreadyRegistered',
    'Bu telefon numarası başka bir hesapta kayıtlı.':
        'authPhoneAlreadyRegistered',
    'LinkedIn yetkilendirme kodu gereklidir.': 'authLinkedInCodeRequired',
    'Geçersiz yönlendirme adresi.': 'authInvalidRedirectUri',
    'LinkedIn oturumu doğrulanamadı.': 'authLinkedInSessionInvalid',
    'LinkedIn hesabına bağlı kullanıcı bulunamadı.':
        'authLinkedInUserNotFound',
    'OTP code is invalid or expired.': 'authInvalidOtp',
    AppErrorKeys.connectionError: 'connectionError',
    AppErrorKeys.supportRequestFailed: 'supportRequestFailed',
    AppErrorKeys.supportRequestFailedRetry: 'supportRequestFailedRetry',
    AppErrorKeys.supportInvalidRequest: 'supportInvalidRequest',
  };
}
