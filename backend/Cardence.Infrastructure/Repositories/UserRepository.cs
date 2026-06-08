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
        return await _dbContext.Users.FirstOrDefaultAsync(
            user => user.Email == email,
            cancellationToken);
    }

    public async Task<User?> GetByPhoneAsync(string phone, CancellationToken cancellationToken = default)
    {
        return await _dbContext.Users.FirstOrDefaultAsync(
            user => user.Phone == phone,
            cancellationToken);
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
}
