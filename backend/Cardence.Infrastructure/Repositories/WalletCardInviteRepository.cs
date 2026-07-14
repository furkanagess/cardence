using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class WalletCardInviteRepository : IWalletCardInviteRepository
{
    private readonly CardenceDbContext _dbContext;

    public WalletCardInviteRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public Task<WalletCardInvite?> GetPendingByInviteeAndInviterAsync(
        Guid inviteeUserId,
        Guid inviterUserId,
        CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        return _dbContext.WalletCardInvites
            .FirstOrDefaultAsync(
                invite =>
                    invite.InviteeUserId == inviteeUserId &&
                    invite.InviterUserId == inviterUserId &&
                    invite.Status == EventGroupInvitationStatuses.Pending &&
                    invite.ExpiresAtUtc > now,
                cancellationToken);
    }

    public async Task<Guid> UpsertPendingAsync(
        WalletCardInvite invite,
        CancellationToken cancellationToken = default)
    {
        var existing = await GetPendingByInviteeAndInviterAsync(
            invite.InviteeUserId,
            invite.InviterUserId,
            cancellationToken);

        if (existing is not null)
        {
            existing.ProposedCardEntityId = invite.ProposedCardEntityId;
            existing.ProposedCardId = invite.ProposedCardId;
            existing.SavedCardId = invite.SavedCardId;
            existing.ExpiresAtUtc = invite.ExpiresAtUtc;
            existing.CreatedAtUtc = invite.CreatedAtUtc;
            await _dbContext.SaveChangesAsync(cancellationToken);
            return existing.Id;
        }

        _dbContext.WalletCardInvites.Add(invite);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return invite.Id;
    }

    public async Task<IReadOnlyList<WalletCardInvite>> GetPendingForInviteeAsync(
        Guid inviteeUserId,
        CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        return await _dbContext.WalletCardInvites
            .AsNoTracking()
            .Include(invite => invite.InviterUser)
            .Include(invite => invite.ProposedCard)
            .Where(invite =>
                invite.InviteeUserId == inviteeUserId &&
                invite.Status == EventGroupInvitationStatuses.Pending &&
                invite.ExpiresAtUtc > now)
            .OrderByDescending(invite => invite.CreatedAtUtc)
            .ToListAsync(cancellationToken);
    }

    public Task<WalletCardInvite?> GetForInviteeAsync(
        Guid inviteeUserId,
        Guid invitationId,
        CancellationToken cancellationToken = default)
    {
        return _dbContext.WalletCardInvites
            .Include(invite => invite.ProposedCard)
            .Include(invite => invite.InviterUser)
            .FirstOrDefaultAsync(
                invite => invite.Id == invitationId && invite.InviteeUserId == inviteeUserId,
                cancellationToken);
    }

    public Task SaveChangesAsync(CancellationToken cancellationToken = default) =>
        _dbContext.SaveChangesAsync(cancellationToken);
}
