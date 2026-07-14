using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IWalletCardInviteRepository
{
    Task<WalletCardInvite?> GetPendingByInviteeAndInviterAsync(
        Guid inviteeUserId,
        Guid inviterUserId,
        CancellationToken cancellationToken = default);

    Task<Guid> UpsertPendingAsync(
        WalletCardInvite invite,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<WalletCardInvite>> GetPendingForInviteeAsync(
        Guid inviteeUserId,
        CancellationToken cancellationToken = default);

    Task<WalletCardInvite?> GetForInviteeAsync(
        Guid inviteeUserId,
        Guid invitationId,
        CancellationToken cancellationToken = default);

    Task SaveChangesAsync(CancellationToken cancellationToken = default);
}
