/// [IntlPhoneField] için ülke kodu ve ulusal numara ayrıştırması.
class IntlPhoneFieldHelpers {
  IntlPhoneFieldHelpers._();

  static String countryCodeFromPhone(String? full) {
    if (full == null || full.isEmpty) return 'TR';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90')) return 'TR';
    if (digits.startsWith('1')) return 'US';
    if (digits.startsWith('44')) return 'GB';
    if (digits.startsWith('49')) return 'DE';
    if (digits.startsWith('33')) return 'FR';
    return 'TR';
  }

  static String nationalFromPhone(String? full) {
    if (full == null || full.isEmpty) return '';
    final digits = full.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('90') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('1') && digits.length > 1) {
      return digits.substring(1);
    }
    if (digits.startsWith('44') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('49') && digits.length > 2) {
      return digits.substring(2);
    }
    if (digits.startsWith('33') && digits.length > 2) {
      return digits.substring(2);
    }
    return digits;
  }
}
