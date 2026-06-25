/// Kaydedilen kart cüzdanı kapasite sabitleri.
class SavedCardsWalletLimits {
  SavedCardsWalletLimits._();

  static const int freeMaxCards = 15;
  static const int freeMaxOwnBusinessCards = 2;
  static const int freeMaxManualSavedCards = 999999;
  static const int freeMaxEventGroups = 2;
  static const int premiumMaxOwnBusinessCards = 50;

  /// Free kullanıcı için geçerli kayıtlı kart üst sınırı (varsayılan 15).
  static int effectiveFreeMaxCards(int maxCards) =>
      maxCards > 0 ? maxCards : freeMaxCards;
}
