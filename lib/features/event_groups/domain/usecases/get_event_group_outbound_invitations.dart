import '../entities/event_group_outbound_invitation.dart';
import '../repositories/event_group_repository.dart';

class GetEventGroupOutboundInvitations {
  const GetEventGroupOutboundInvitations(this._repository);

  final EventGroupRepository _repository;

  Future<List<EventGroupOutboundInvitation>> call(String groupId) =>
      _repository.getOutboundInvitations(groupId);
}
