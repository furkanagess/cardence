import '../repositories/saved_card_repository.dart';

class RejectWalletCardInvitation {
  const RejectWalletCardInvitation(this._repository);

  final SavedCardRepository _repository;

  Future<void> call(String invitationId) =>
      _repository.rejectWalletCardInvitation(invitationId);
}
