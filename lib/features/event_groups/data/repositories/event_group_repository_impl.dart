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
    final photoFilePath = input.photoFilePath?.trim();
    final created = await _remote.createEventGroup(
      name: input.name,
      location: input.location,
      startAt: input.startAt,
      endAt: input.endAt,
      description: input.description,
      invitedCardIds: input.invitedCardIds,
      photoFilePath: photoFilePath,
      accessToken: token,
    );

    if (photoFilePath != null && photoFilePath.isNotEmpty) {
      if (created.photoUrl == null || created.photoUrl!.trim().isEmpty) {
        await _tryDeleteEventGroup(created.id, token);
        throw AuthApiException('Etkinlik fotoğrafı kaydedilemedi.');
      }
      AuthenticatedImageLoader.evictAllVariants(created.photoUrl);
    }

    final localGroups = await _local.getEventGroups();
    final updated = [...localGroups, created];
    await _cacheGroups(updated);
    return created.toEntity();
  }

  Future<EventGroupModel> _uploadAndValidateEventGroupPhoto({
    required String groupId,
    required String filePath,
    required String accessToken,
  }) async {
    final updated = await _remote.uploadEventGroupPhoto(
      groupId: groupId,
      filePath: filePath,
      accessToken: accessToken,
    );
    if (updated.photoUrl == null || updated.photoUrl!.trim().isEmpty) {
      throw AuthApiException('Etkinlik fotoğrafı kaydedilemedi.');
    }
    AuthenticatedImageLoader.evictAllVariants(updated.photoUrl);
    return updated;
  }

  Future<void> _tryDeleteEventGroup(String groupId, String accessToken) async {
    try {
      await _remote.deleteEventGroup(groupId: groupId, accessToken: accessToken);
    } catch (_) {
      // Fotoğraf yüklemesi başarısız oldu; grubu silmek için en iyi çaba.
    }
  }

  Future<EventGroupModel> _upsertLocalGroup(EventGroupModel updated) async {
    final localGroups = await _local.getEventGroups();
    final index = localGroups.indexWhere((group) => group.id == updated.id);
    final next = [...localGroups];
    var merged = updated;
    if (index >= 0) {
      final existing = next[index];
      final updatedPhoto = updated.photoUrl?.trim();
      final existingPhoto = existing.photoUrl?.trim();
      if ((updatedPhoto == null || updatedPhoto.isEmpty) &&
          existingPhoto != null &&
          existingPhoto.isNotEmpty) {
        merged = EventGroupModel(
          id: updated.id,
          name: updated.name,
          location: updated.location,
          description: updated.description,
          startAt: updated.startAt,
          endAt: updated.endAt,
          status: updated.status,
          eventDate: updated.eventDate,
          photoUrl: existing.photoUrl,
          invalidCardIds: updated.invalidCardIds,
        );
      }
      next[index] = merged;
    } else {
      next.add(merged);
    }
    await _cacheGroups(next);
    return merged;
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
      updated = await _uploadAndValidateEventGroupPhoto(
        groupId: updated.id,
        filePath: photoFilePath,
        accessToken: token,
      );
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
