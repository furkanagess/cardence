using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class SubscriptionEventRepository : ISubscriptionEventRepository
{
    private readonly CardenceDbContext _dbContext;

    public SubscriptionEventRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<bool> ExistsAsync(
        string provider,
        string providerEventId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.SubscriptionEvents.AnyAsync(
            e => e.Provider == provider && e.ProviderEventId == providerEventId,
            cancellationToken);
    }

    public async Task AddAsync(
        SubscriptionEvent subscriptionEvent,
        CancellationToken cancellationToken = default)
    {
        _dbContext.SubscriptionEvents.Add(subscriptionEvent);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
