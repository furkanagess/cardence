/// Kayıtlı kartın cüzdana nasıl eklendiğini belirtir.
enum SavedCardOrigin {
  /// Elle girilen veya kartvizit fotoğrafı ile eklenen kart.
  manual,

  /// Cardence kart ID'si ile eklenen platform kullanıcısı.
  cardence,
}
