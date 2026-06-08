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
}
