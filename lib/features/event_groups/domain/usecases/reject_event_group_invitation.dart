import '../repositories/event_group_repository.dart';

class RejectEventGroupInvitation {
  const RejectEventGroupInvitation(this._repository);
  final EventGroupRepository _repository;

  Future<void> call(String invitationId) =>
      _repository.rejectInvitation(invitationId);
}
