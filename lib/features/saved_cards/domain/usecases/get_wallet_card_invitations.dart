import '../entities/wallet_card_invitation.dart';
import '../repositories/saved_card_repository.dart';

class GetWalletCardInvitations {
  const GetWalletCardInvitations(this._repository);

  final SavedCardRepository _repository;

  Future<List<WalletCardInvitation>> call() =>
      _repository.getPendingWalletCardInvitations();
}
