/// Sunucuda üretilen görsel varyant genişlikleri (px).
enum MediaImageSize {
  /// Liste / küçük avatar (128px)
  thumb(128),

  /// Orta avatar / sıkı önizleme (256px)
  small(256),

  /// Kart yüzü / detay başlığı (512px)
  medium(512),

  /// Tam çözünürlük önizleme (1024px)
  large(1024);

  const MediaImageSize(this.width);
  final int width;
}
