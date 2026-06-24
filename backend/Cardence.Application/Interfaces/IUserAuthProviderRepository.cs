using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IUserAuthProviderRepository
{
    Task<UserAuthProvider?> GetByProviderAsync(
        string providerId,
        string providerUserId,
        CancellationToken cancellationToken = default);

    Task AddAsync(
        UserAuthProvider provider,
        CancellationToken cancellationToken = default);
}
