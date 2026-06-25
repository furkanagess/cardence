using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface ISubscriptionEventRepository
{
    Task<bool> ExistsAsync(
        string provider,
        string providerEventId,
        CancellationToken cancellationToken = default);

    Task AddAsync(
        SubscriptionEvent subscriptionEvent,
        CancellationToken cancellationToken = default);
}
