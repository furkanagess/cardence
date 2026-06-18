import '../constants/app_constants.dart';

/// Kart ön yüzünde gösterilecek iletişim alanı kuralları.
class CardContactVisibility {
  CardContactVisibility._();

  static const List<String> frontContactFieldKeys = [
    'email',
    'phone',
    'linkedin',
    'website',
  ];

  /// Tercih sırasına göre, değeri olan en fazla [AppConstants.maxFrontCardFields] alan.
  static List<String> limitedFrontContactKeys({
    required List<String> preferredOrder,
    required bool Function(String key) hasValue,
  }) {
    final order = preferredOrder.isNotEmpty
        ? preferredOrder
        : frontContactFieldKeys;
    return order
        .where((key) => frontContactFieldKeys.contains(key) && hasValue(key))
        .take(AppConstants.maxFrontCardFields)
        .toList();
  }

  /// Seçim listesini geçerli anahtarlarla sınırlar (en fazla 3).
  static List<String> normalizeFrontContactFields(List<String> fields) {
    return fields
        .where(frontContactFieldKeys.contains)
        .take(AppConstants.maxFrontCardFields)
        .toList();
  }
}
