import '../../features/auth/domain/entities/user_profile.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/sync_onboarding_from_server.dart';
import '../../features/saved_cards/domain/repositories/saved_card_repository.dart';

/// Sunucudan gelen profil kartlarını kullanıcıya özel yerel depoya yazar.
class SyncUserProfileCards {
  const SyncUserProfileCards(
    this._savedCardRepository,
    this._onboardingRepository,
    this._syncOnboardingFromServer,
  );

  final SavedCardRepository _savedCardRepository;
  final OnboardingRepository _onboardingRepository;
  final SyncOnboardingFromServer _syncOnboardingFromServer;

  Future<void> call(UserProfile profile) async {
    await _savedCardRepository.cacheFromProfile(profile.savedCards);
    await _onboardingRepository.syncBusinessCardsFromProfile(
      profile.businessCards,
    );
    await _syncOnboardingFromServer(completed: profile.onboardingCompleted);
  }
}
