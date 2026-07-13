import '../../../saved_cards/domain/repositories/saved_card_repository.dart';

/// Sunucu tarafında wallet tier ve `isOwnerPremium` bayraklarını RevenueCat ile senkronize eder.
class FinalizePremiumWalletActivation {
  const FinalizePremiumWalletActivation(this._savedCardRepository);

  final SavedCardRepository _savedCardRepository;

  Future<void> call() => _savedCardRepository.syncWalletPremium();
}
