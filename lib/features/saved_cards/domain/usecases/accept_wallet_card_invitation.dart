import '../repositories/saved_card_repository.dart';

class AcceptWalletCardInvitation {
  const AcceptWalletCardInvitation(this._repository);

  final SavedCardRepository _repository;

  Future<void> call(String invitationId) =>
      _repository.acceptWalletCardInvitation(invitationId);
}
