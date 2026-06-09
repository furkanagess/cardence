import 'dart:math';

/// Kart kimliği: tam 6 haneli sayı (000000–999999).
class CardIdGenerator {
  CardIdGenerator._();

  static const int length = 6;

  static final Random _random = Random();

  static final RegExp cardIdPattern = RegExp(r'^\d{6}$');

  static bool isValid(String? cardId) {
    final id = cardId?.trim();
    if (id == null || id.isEmpty) return false;
    return cardIdPattern.hasMatch(id);
  }

  static String generate() {
    return _random.nextInt(1000000).toString().padLeft(6, '0');
  }
}
