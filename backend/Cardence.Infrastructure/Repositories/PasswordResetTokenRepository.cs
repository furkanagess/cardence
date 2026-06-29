using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class PasswordResetTokenRepository : IPasswordResetTokenRepository
{
    private readonly CardenceDbContext _dbContext;

    public PasswordResetTokenRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task AddAsync(PasswordResetToken token, CancellationToken cancellationToken = default)
    {
        _dbContext.PasswordResetTokens.Add(token);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<PasswordResetToken?> GetValidByTokenHashAsync(
        string tokenHash,
        CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        return await _dbContext.PasswordResetTokens
            .Include(x => x.User)
            .FirstOrDefaultAsync(
                x => x.TokenHash == tokenHash
                     && x.UsedAt == null
                     && x.ExpiresAt > now,
                cancellationToken);
    }

    public async Task InvalidateActiveTokensAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var activeTokens = await _dbContext.PasswordResetTokens
            .Where(x => x.UserId == userId && x.UsedAt == null && x.ExpiresAt > now)
            .ToListAsync(cancellationToken);

        if (activeTokens.Count == 0)
        {
            return;
        }

        foreach (var token in activeTokens)
        {
            token.UsedAt = now;
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(PasswordResetToken token, CancellationToken cancellationToken = default)
    {
        _dbContext.PasswordResetTokens.Update(token);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
