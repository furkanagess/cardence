import 'package:flutter/material.dart';

import '../../../auth/domain/usecases/upload_profile_photo.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../../saved_cards/domain/usecases/upgrade_wallet_plan.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../pages/onboarding_page.dart';

/// Profilden ek kart oluştururken onboarding adımlarını açar.
abstract final class AdditionalCardOnboardingLauncher {
  static Future<OnboardingCardDraft?> open(
    BuildContext context, {
    required OnboardingCardDraft initialDraft,
    required PersistOnboardingCard persistOnboardingCard,
    required UploadProfilePhoto uploadProfilePhoto,
    required UpgradeWalletPlan upgradeWalletPlan,
  }) {
    return Navigator.of(context).push<OnboardingCardDraft>(
      MaterialPageRoute(
        builder: (routeContext) => OnboardingPageView(
          initialDraft: initialDraft,
          persistOnboardingCard: persistOnboardingCard,
          uploadProfilePhoto: uploadProfilePhoto,
          upgradeWalletPlan: upgradeWalletPlan,
          onFinish: (draft) => Navigator.of(routeContext).pop(draft),
        ),
      ),
    );
  }
}
