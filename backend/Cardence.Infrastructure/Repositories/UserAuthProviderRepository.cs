using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class UserAuthProviderRepository : IUserAuthProviderRepository
{
    private readonly CardenceDbContext _dbContext;

    public UserAuthProviderRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<UserAuthProvider?> GetByProviderAsync(
        string providerId,
        string providerUserId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.UserAuthProviders.FirstOrDefaultAsync(
            provider =>
                provider.ProviderId == providerId
                && provider.ProviderUserId == providerUserId,
            cancellationToken);
    }

    public async Task AddAsync(
        UserAuthProvider provider,
        CancellationToken cancellationToken = default)
    {
        _dbContext.UserAuthProviders.Add(provider);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
