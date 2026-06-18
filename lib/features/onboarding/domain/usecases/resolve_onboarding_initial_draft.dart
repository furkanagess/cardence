import '../../../auth/domain/usecases/get_current_user.dart';
import '../entities/onboarding_card_draft.dart';
import '../helpers/onboarding_draft_helper.dart';
import '../onboarding_draft_seeder.dart';
import 'get_onboarding_draft_card.dart';

/// Onboarding açılışında taslak: yerel kayıt + oturumdaki kullanıcı bilgisi.
class ResolveOnboardingInitialDraft {
  const ResolveOnboardingInitialDraft(
    this._getDraftCard,
    this._getCurrentUser,
  );

  final GetOnboardingDraftCard _getDraftCard;
  final GetCurrentUser _getCurrentUser;

  Future<OnboardingCardDraft> call() async {
    final saved = await _getDraftCard();
    var draft = saved ?? OnboardingDraftSeeder.defaultDraft();

    try {
      final profile = await _getCurrentUser();
      draft = OnboardingDraftSeeder.applyUserProfile(draft, profile);
    } catch (_) {
      // Profil alınamazsa mevcut taslak veya varsayılan ile devam.
    }

    return OnboardingDraftHelper.ensureCardId(draft);
  }
}
