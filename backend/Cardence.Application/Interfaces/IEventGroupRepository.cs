using Cardence.Application.DTOs.EventGroups;
using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IEventGroupRepository
{
    Task<IReadOnlyList<EventGroup>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<EventGroup?> GetByUserAndIdAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default);

    Task<EventGroup?> GetByUserAndNameAsync(
        Guid userId,
        string name,
        CancellationToken cancellationToken = default);

    Task<int> CountCardsInGroupAsync(
        Guid groupId,
        CancellationToken cancellationToken = default);

    Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task AddAsync(EventGroup group, CancellationToken cancellationToken = default);

    Task UpdateAsync(EventGroup group, CancellationToken cancellationToken = default);

    Task DeleteAsync(EventGroup group, CancellationToken cancellationToken = default);

    Task LinkCardsAsync(
        Guid userId,
        Guid groupId,
        IReadOnlyList<string> cardIds,
        CancellationToken cancellationToken = default);

    Task<EventGroupInviteCardsResult> InviteCardsByCardIdsAsync(
        Guid userId,
        Guid groupId,
        IReadOnlyList<string> cardIds,
        CancellationToken cancellationToken = default);

    Task UnlinkCardAsync(
        Guid userId,
        Guid groupId,
        string cardId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SavedCard>> GetCardsInGroupAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default);

    Task SyncWalletCardLinksAsync(
        Guid userId,
        string cardId,
        IReadOnlyList<string> groupIds,
        CancellationToken cancellationToken = default);

    Task PopulateLinkedGroupIdsAsync(
        IReadOnlyList<SavedCard> cards,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<EventGroupCardInvite>> GetPendingInvitationsForInviteeAsync(
        Guid inviteeUserId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<EventGroupCardInvite>> GetOutboundInvitationsForGroupAsync(
        Guid ownerUserId,
        Guid groupId,
        CancellationToken cancellationToken = default);

    Task<EventGroupCardInvite?> GetInvitationForInviteeAsync(
        Guid inviteeUserId,
        Guid invitationId,
        CancellationToken cancellationToken = default);

    Task AcceptInvitationAsync(
        EventGroupCardInvite invitation,
        CancellationToken cancellationToken = default);

    Task RejectInvitationAsync(
        EventGroupCardInvite invitation,
        CancellationToken cancellationToken = default);

    Task DeleteExpiredInvitationsAsync(CancellationToken cancellationToken = default);
}
