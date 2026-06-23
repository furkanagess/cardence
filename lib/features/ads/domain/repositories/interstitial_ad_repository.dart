abstract class InterstitialAdRepository {
  Future<void> initialize();

  Future<void> preload();

  Future<bool> show();
}
