using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Auth;

public sealed class EfAuthTokenStore : IAuthTokenStore
{
    private readonly CardenceDbContext _dbContext;
    private readonly InMemoryAuthTokenStore _otpStore = new();

    public EfAuthTokenStore(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public Task SaveOtpAsync(
        string key,
        string code,
        TimeSpan lifetime,
        CancellationToken cancellationToken = default) =>
        _otpStore.SaveOtpAsync(key, code, lifetime, cancellationToken);

    public Task<bool> ValidateOtpAsync(
        string key,
        string code,
        CancellationToken cancellationToken = default) =>
        _otpStore.ValidateOtpAsync(key, code, cancellationToken);

    public async Task SaveRefreshTokenAsync(
        Guid userId,
        string token,
        DateTime expiresAtUtc,
        CancellationToken cancellationToken = default)
    {
        var existing = await _dbContext.AuthRefreshTokens
            .Where(x => x.UserId == userId)
            .ToListAsync(cancellationToken);

        if (existing.Count > 0)
        {
            _dbContext.AuthRefreshTokens.RemoveRange(existing);
        }

        _dbContext.AuthRefreshTokens.Add(new AuthRefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Token = token,
            ExpiresAtUtc = expiresAtUtc,
            CreatedAtUtc = DateTime.UtcNow,
        });

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<Guid?> GetUserIdByRefreshTokenAsync(
        string token,
        CancellationToken cancellationToken = default)
    {
        var entry = await _dbContext.AuthRefreshTokens
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Token == token, cancellationToken);

        if (entry is null)
        {
            return null;
        }

        if (entry.ExpiresAtUtc < DateTime.UtcNow)
        {
            var tracked = await _dbContext.AuthRefreshTokens
                .FirstOrDefaultAsync(x => x.Id == entry.Id, cancellationToken);
            if (tracked is not null)
            {
                _dbContext.AuthRefreshTokens.Remove(tracked);
                await _dbContext.SaveChangesAsync(cancellationToken);
            }

            return null;
        }

        return entry.UserId;
    }
}
