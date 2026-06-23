/// Mağaza bağlantıları ve uygulama kimlikleri.
class StoreConfig {
  StoreConfig._();

  static const String androidApplicationId = 'com.furkanages.cardenceapp';

  /// App Store Connect'teki sayısal uygulama kimliği (yayın sonrası güncellenir).
  static const String? iosAppStoreId = null;

  static Uri playStoreListingUri() => Uri.parse(
        'https://play.google.com/store/apps/details?id=$androidApplicationId',
      );

  static Uri? appStoreListingUri() {
    final id = iosAppStoreId;
    if (id == null || id.isEmpty) return null;
    return Uri.parse('https://apps.apple.com/app/id$id');
  }
}
