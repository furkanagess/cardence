/// Kartın cüzdana / sisteme nasıl eklendiğini belirtir (API `creationMethod`).
enum CardCreationMethod {
  manual('manual'),
  photoScan('photo_scan'),
  cardenceLink('cardence_link'),
  qrScan('qr_scan');

  const CardCreationMethod(this.apiValue);

  final String apiValue;

  bool get isManualEntry => this == manual || this == photoScan;

  static CardCreationMethod? fromApi(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toLowerCase();
    for (final method in CardCreationMethod.values) {
      if (method.apiValue == normalized) return method;
    }
    return null;
  }
}
