/// Uygulama genelinde metin doğrulama kuralları (regex).
class AppValidators {
  AppValidators._();

  /// Ad / soyad: en az 2 karakter; boşluklu ad soyad desteklenir.
  static final RegExp personName = RegExp(
    r"^[a-zA-ZğüşöçıİĞÜŞÖÇ][a-zA-ZğüşöçıİĞÜŞÖÇ'\-\.\s]{1,}$",
  );

  /// Şirket / pozisyon: harf, rakam ve yaygın noktalama.
  static final RegExp organizationText = RegExp(
    r"^[a-zA-ZğüşöçıİĞÜŞÖÇ0-9][a-zA-ZğüşöçıİĞÜŞÖÇ0-9\s&\.,'\-]{1,}$",
  );

  /// E-posta.
  static final RegExp email = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static const int minPasswordLength = 8;

  /// E.164 formatı üst sınırı (backend `VARCHAR(20)`).
  static const int maxPhoneLength = 20;

  /// E.164 rakam aralığı (ülke kodu + ulusal numara).
  static const int minPhoneDigits = 8;
  static const int maxPhoneDigits = 15;

  /// Yetenek etiketi (ör. Flutter, C#, UI/UX).
  static final RegExp skillToken = RegExp(
    r"^[a-zA-ZğüşöçıİĞÜŞÖÇ0-9][a-zA-ZğüşöçıİĞÜŞÖÇ0-9+#./\-\s]{1,}$",
  );

  static bool matches(RegExp pattern, String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return false;
    return pattern.hasMatch(trimmed);
  }

  /// Yetenek ekleme alanındaki metin ekle butonu için geçerli mi.
  static bool isValidSkillDraft(String? value) {
    return matches(skillToken, value);
  }

  static bool isValidPassword(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.length >= minPasswordLength;
  }

  /// Kayıt vb. isteğe bağlı telefon alanı için hata metni; geçerliyse `null`.
  static String? optionalPhoneError(String? completeNumber) {
    final phone = completeNumber?.trim() ?? '';
    if (phone.isEmpty) return null;
    if (phone.length > maxPhoneLength) {
      return 'Telefon numarası en fazla $maxPhoneLength karakter olabilir.';
    }
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < minPhoneDigits || digits.length > maxPhoneDigits) {
      return 'Geçerli bir telefon numarası girin.';
    }
    return null;
  }
}
