import '../../../saved_cards/domain/repositories/saved_card_repository.dart';

/// Sunucu tarafında premium cüzdan kotasını ve `isOwnerPremium` bayrağını senkronize eder.
class FinalizePremiumWalletActivation {
  const FinalizePremiumWalletActivation(this._savedCardRepository);

  final SavedCardRepository _savedCardRepository;

  Future<void> call() => _savedCardRepository.syncWalletPremium();
}
