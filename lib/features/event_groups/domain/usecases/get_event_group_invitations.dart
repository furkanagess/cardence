import '../entities/event_group_invitation.dart';
import '../repositories/event_group_repository.dart';

class GetEventGroupInvitations {
  const GetEventGroupInvitations(this._repository);
  final EventGroupRepository _repository;

  Future<List<EventGroupInvitation>> call() =>
      _repository.getPendingInvitations();
}
