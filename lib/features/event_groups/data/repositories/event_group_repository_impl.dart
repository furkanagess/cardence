import '../../../../core/auth/auth_token_provider.dart';
import '../../../../core/media/authenticated_image_loader.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/event_group.dart';
import '../../domain/entities/event_group_create_input.dart';
import '../../domain/entities/event_group_invitation.dart';
import '../../domain/entities/event_group_update_input.dart';
import '../../domain/repositories/event_group_repository.dart';
import '../datasources/event_group_local_datasource.dart';
import '../datasources/event_group_remote_datasource.dart';
import '../models/event_group_model.dart';

class EventGroupRepositoryImpl implements EventGroupRepository {
  EventGroupRepositoryImpl({
    required EventGroupLocalDataSource local,
    required EventGroupRemoteDataSource remote,
    required AuthTokenProvider authTokens,
  })  : _local = local,
        _remote = remote,
        _authTokens = authTokens;

  final EventGroupLocalDataSource _local;
  final EventGroupRemoteDataSource _remote;
  final AuthTokenProvider _authTokens;

  Future<String?> _tryAccessToken() => _authTokens.tryAccessToken();

  Future<String> _requireAccessToken() => _authTokens.requireAccessToken();

  Future<void> _cacheGroups(List<EventGroupModel> groups) async {
    await _local.replaceAll(groups);
  }

  @override
  Future<List<EventGroup>> getEventGroups() async {
    final token = await _tryAccessToken();
    if (token != null) {
      try {
        final remoteGroups = await _remote.getEventGroups(accessToken: token);
        await _cacheGroups(remoteGroups);
        return remoteGroups.map((model) => model.toEntity()).toList();
      } on AuthApiException catch (e) {
        if (!e.isNetworkError) rethrow;
      } catch (_) {
        // Sunucu erişilemezse yerel önbelleğe düş.
      }
    }

    final localGroups = await _local.getEventGroups();
    return localGroups.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<EventGroupInvitation>> getPendingInvitations() async {
    final token = await _tryAccessToken();
    if (token == null) return [];

    try {
      final invitations = await _remote.getPendingInvitations(
        accessToken: token,
      );
      return invitations.map((model) => model.toEntity()).toList();
    } on AuthApiException catch (e) {
      if (e.isNetworkError || e.statusCode == 404) return [];
      rethrow;
    }
  }

  @override
  Future<void> acceptInvitation(String invitationId) async {
    final token = await _requireAccessToken();
    await _remote.acceptInvitation(
      invitationId: invitationId,
      accessToken: token,
    );
  }

  @override
  Future<void> rejectInvitation(String invitationId) async {
    final token = await _requireAccessToken();
    await _remote.rejectInvitation(
      invitationId: invitationId,
      accessToken: token,
    );
  }

  @override
  Future<EventGroup> createEventGroup(EventGroupCreateInput input) async {
    final token = await _requireAccessToken();
    var created = await _remote.createEventGroup(
      name: input.name,
      location: input.location,
      startAt: input.startAt,
      endAt: input.endAt,
      description: input.description,
      invitedCardIds: input.invitedCardIds,
      accessToken: token,
    );

    final photoFilePath = input.photoFilePath?.trim();
    if (photoFilePath != null && photoFilePath.isNotEmpty) {
      created = await _remote.uploadEventGroupPhoto(
        groupId: created.id,
        filePath: photoFilePath,
        accessToken: token,
      );
      AuthenticatedImageLoader.evictAllVariants(created.photoUrl);
    }

    final localGroups = await _local.getEventGroups();
    final updated = [...localGroups, created];
    await _cacheGroups(updated);
    return created.toEntity();
  }

  Future<EventGroupModel> _upsertLocalGroup(EventGroupModel updated) async {
    final localGroups = await _local.getEventGroups();
    final index = localGroups.indexWhere((group) => group.id == updated.id);
    final next = [...localGroups];
    if (index >= 0) {
      next[index] = updated;
    } else {
      next.add(updated);
    }
    await _cacheGroups(next);
    return updated;
  }

  @override
  Future<EventGroup> updateEventGroup(EventGroupUpdateInput input) async {
    final token = await _requireAccessToken();
    var updated = await _remote.updateEventGroup(
      groupId: input.id,
      name: input.name,
      location: input.location,
      startAt: input.startAt,
      endAt: input.endAt,
      description: input.description,
      clearPhoto: input.clearPhoto,
      accessToken: token,
    );

    final photoFilePath = input.photoFilePath?.trim();
    if (photoFilePath != null && photoFilePath.isNotEmpty) {
      updated = await _remote.uploadEventGroupPhoto(
        groupId: updated.id,
        filePath: photoFilePath,
        accessToken: token,
      );
      AuthenticatedImageLoader.evictAllVariants(updated.photoUrl);
    } else if (input.clearPhoto) {
      AuthenticatedImageLoader.evictAllVariants(updated.photoUrl);
    }

    await _upsertLocalGroup(updated);
    return updated.toEntity();
  }

  @override
  Future<EventGroup> inviteCardsByCardId({
    required String groupId,
    required List<String> cardIds,
  }) async {
    if (cardIds.isEmpty) {
      final groups = await getEventGroups();
      final existing = groups.firstWhere(
        (group) => group.id == groupId,
        orElse: () => throw AuthApiException('Etkinlik grubu bulunamadı.'),
      );
      return existing;
    }

    final token = await _requireAccessToken();
    final updated = await _remote.inviteCardsByCardId(
      groupId: groupId,
      cardIds: cardIds,
      accessToken: token,
    );
    await _upsertLocalGroup(updated);
    return updated.toEntity();
  }

  @override
  Future<void> deleteEventGroup(String groupId) async {
    final token = await _requireAccessToken();
    await _remote.deleteEventGroup(groupId: groupId, accessToken: token);
    final localGroups = await _local.getEventGroups();
    final updated = localGroups.where((group) => group.id != groupId).toList();
    await _cacheGroups(updated);
  }

  @override
  Future<void> linkCards({
    required String groupId,
    required List<String> cardIds,
  }) async {
    if (cardIds.isEmpty) return;
    final token = await _requireAccessToken();
    await _remote.linkCards(
      groupId: groupId,
      cardIds: cardIds,
      accessToken: token,
    );
  }

  @override
  Future<void> unlinkCard({
    required String groupId,
    required String cardId,
  }) async {
    final token = await _requireAccessToken();
    await _remote.unlinkCard(
      groupId: groupId,
      cardId: cardId,
      accessToken: token,
    );
  }
}
