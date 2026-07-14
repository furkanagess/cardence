using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class UserDeviceTokenRepository : IUserDeviceTokenRepository
{
    private readonly CardenceDbContext _dbContext;

    public UserDeviceTokenRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public Task<UserDeviceToken?> GetByUserAndTokenAsync(
        Guid userId,
        string token,
        CancellationToken cancellationToken = default)
    {
        return _dbContext.UserDeviceTokens
            .FirstOrDefaultAsync(
                entry => entry.UserId == userId && entry.Token == token,
                cancellationToken);
    }

    public async Task<IReadOnlyList<string>> GetTokensByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.UserDeviceTokens
            .AsNoTracking()
            .Where(entry => entry.UserId == userId)
            .Select(entry => entry.Token)
            .Distinct()
            .ToListAsync(cancellationToken);
    }

    public async Task UpsertAsync(
        UserDeviceToken token,
        CancellationToken cancellationToken = default)
    {
        var tracked = await _dbContext.UserDeviceTokens
            .FirstOrDefaultAsync(
                entry => entry.Id == token.Id,
                cancellationToken);

        if (tracked is null)
        {
            var existingByToken = await _dbContext.UserDeviceTokens
                .FirstOrDefaultAsync(
                    entry => entry.UserId == token.UserId && entry.Token == token.Token,
                    cancellationToken);
            if (existingByToken is not null)
            {
                existingByToken.Platform = token.Platform;
                existingByToken.UpdatedAt = token.UpdatedAt;
            }
            else
            {
                _dbContext.UserDeviceTokens.Add(token);
            }
        }
        else
        {
            tracked.Platform = token.Platform;
            tracked.UpdatedAt = token.UpdatedAt;
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteByUserAndTokenAsync(
        Guid userId,
        string token,
        CancellationToken cancellationToken = default)
    {
        await _dbContext.UserDeviceTokens
            .Where(entry => entry.UserId == userId && entry.Token == token)
            .ExecuteDeleteAsync(cancellationToken);
    }

    public async Task DeleteTokensAsync(
        IReadOnlyList<string> tokens,
        CancellationToken cancellationToken = default)
    {
        if (tokens.Count == 0)
        {
            return;
        }

        await _dbContext.UserDeviceTokens
            .Where(entry => tokens.Contains(entry.Token))
            .ExecuteDeleteAsync(cancellationToken);
    }
}
