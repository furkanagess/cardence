import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/saved_cards/data/datasources/saved_card_local_datasource.dart';

/// Oturum kapanırken kullanıcıya özel yerel kart verilerini temizler.
class ClearUserScopedLocalData {
  const ClearUserScopedLocalData(
    this._authLocal,
    this._savedCardLocal,
    this._onboardingLocal,
  );

  final AuthLocalDataSource _authLocal;
  final SavedCardLocalDataSource _savedCardLocal;
  final OnboardingLocalDataSource _onboardingLocal;

  Future<void> call() async {
    final session = await _authLocal.getSession();
    final userId = session?.userId;
    if (userId == null || userId.isEmpty) return;
    await _savedCardLocal.clearForUser(userId);
    await _onboardingLocal.clearForUser(userId);
  }
}
