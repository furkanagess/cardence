import 'dart:math';

/// Kart kimliği: tam 6 haneli sayı (000000–999999).
///
/// - Cardence iş kartları: 000000–899999
/// - Manuel cüzdan kartları: 900000–999999
class CardIdGenerator {
  CardIdGenerator._();

  static const int length = 6;

  static const int businessCardIdMaxExclusive = 900000;
  static const int manualWalletCardIdMin = 900000;

  static final Random _random = Random();

  static final RegExp cardIdPattern = RegExp(r'^\d{6}$');

  static bool isValid(String? cardId) {
    final id = cardId?.trim();
    if (id == null || id.isEmpty) return false;
    return cardIdPattern.hasMatch(id);
  }

  static bool isManualWalletId(String? cardId) {
    if (!isValid(cardId)) return false;
    final numeric = int.parse(cardId!.trim());
    return numeric >= manualWalletCardIdMin;
  }

  /// Cardence iş kartı için aday kimlik (000000–899999).
  static String generateBusinessCandidate() {
    return _random
        .nextInt(businessCardIdMaxExclusive)
        .toString()
        .padLeft(length, '0');
  }

  /// Manuel cüzdan kartı için kimlik (900000–999999).
  static String generateManualWallet() {
    return (manualWalletCardIdMin +
            _random.nextInt(1000000 - manualWalletCardIdMin))
        .toString()
        .padLeft(length, '0');
  }
}
