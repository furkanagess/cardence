import '../repositories/event_group_repository.dart';

class AcceptEventGroupInvitation {
  const AcceptEventGroupInvitation(this._repository);
  final EventGroupRepository _repository;

  Future<void> call(String invitationId) =>
      _repository.acceptInvitation(invitationId);
}
