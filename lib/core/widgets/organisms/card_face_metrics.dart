/// Kartvizit yüzü ölçüleri — telefon tasarım genişliğine göre ölçeklenir.
///
/// iPad gibi geniş cihazlarda sabit font/padding sırıtmasın diye
/// [fromWidth] ile üretilir; tüm kart yüzü bileşenleri [s] kullanır.
class CardFaceMetrics {
  const CardFaceMetrics(this.scale);

  /// Telefon önizlemesindeki tipik kart içeriği genişliği (logical px).
  static const double designWidth = 340;

  static const double minScale = 0.88;
  static const double maxScale = 1.85;

  final double scale;

  factory CardFaceMetrics.fromWidth(double width) {
    if (!width.isFinite || width <= 0) {
      return const CardFaceMetrics(1);
    }
    return CardFaceMetrics(
      (width / designWidth).clamp(minScale, maxScale).toDouble(),
    );
  }

  double s(double value) => value * scale;
}
