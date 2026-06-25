using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class WalletEntitlementRepository : IWalletEntitlementRepository
{
    private readonly CardenceDbContext _dbContext;

    public WalletEntitlementRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<WalletEntitlement> GetOrCreateAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var existing = await _dbContext.WalletEntitlements
            .FirstOrDefaultAsync(entitlement => entitlement.UserId == userId, cancellationToken);

        if (existing is not null)
        {
            return existing;
        }

        var created = new WalletEntitlement
        {
            UserId = userId,
            Tier = WalletConstants.FreeTier,
            MaxCards = WalletConstants.FreeMaxCards,
            UpdatedAt = DateTime.UtcNow,
        };

        _dbContext.WalletEntitlements.Add(created);
        await _dbContext.SaveChangesAsync(cancellationToken);
        return created;
    }

    public async Task<WalletEntitlement> UpgradeToPremiumAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await SetTierAsync(
            userId,
            WalletConstants.PremiumTier,
            WalletConstants.PremiumMaxCards,
            cancellationToken);
    }

    public async Task<WalletEntitlement> SetTierAsync(
        Guid userId,
        string tier,
        int maxCards,
        CancellationToken cancellationToken = default)
    {
        var entitlement = await GetOrCreateAsync(userId, cancellationToken);
        entitlement.Tier = WalletConstants.NormalizeTier(tier);
        entitlement.MaxCards = maxCards;
        entitlement.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);
        return entitlement;
    }
}
