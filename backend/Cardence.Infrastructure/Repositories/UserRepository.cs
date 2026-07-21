using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class UserRepository : IUserRepository
{
    private readonly CardenceDbContext _dbContext;

    public UserRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<User?> GetByIdAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await _dbContext.Users.FirstOrDefaultAsync(user => user.Id == userId, cancellationToken);
    }

    public async Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        var normalizedEmail = email.Trim().ToLowerInvariant();
        return await _dbContext.Users.FirstOrDefaultAsync(
            user => user.Email != null && user.Email.ToLower() == normalizedEmail,
            cancellationToken);
    }

    public async Task<User?> GetByPhoneAsync(string phone, CancellationToken cancellationToken = default)
    {
        var normalizedPhone = PhoneNormalizer.Normalize(phone);
        if (string.IsNullOrEmpty(normalizedPhone))
        {
            return null;
        }

        var candidates = await _dbContext.Users
            .Where(user => user.Phone != null && user.Phone != string.Empty)
            .ToListAsync(cancellationToken);

        return candidates.FirstOrDefault(
            user => PhoneNormalizer.AreEquivalent(user.Phone, normalizedPhone));
    }

    public async Task AddAsync(User user, CancellationToken cancellationToken = default)
    {
        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(User user, CancellationToken cancellationToken = default)
    {
        _dbContext.Users.Update(user);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(User user, CancellationToken cancellationToken = default)
    {
        _dbContext.Users.Remove(user);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
