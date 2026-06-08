using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class SavedCardRepository : ISavedCardRepository
{
    private readonly CardenceDbContext _dbContext;

    public SavedCardRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<SavedCard>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.SavedCards
            .AsNoTracking()
            .Where(card => card.UserId == userId)
            .OrderBy(card => card.SortOrder)
            .ThenByDescending(card => card.SavedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<SavedCard?> GetByUserAndCardIdAsync(
        Guid userId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.SavedCards
            .FirstOrDefaultAsync(
                card => card.UserId == userId && card.CardId == cardId,
                cancellationToken);
    }

    public async Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.SavedCards
            .CountAsync(card => card.UserId == userId, cancellationToken);
    }

    public async Task AddAsync(SavedCard card, CancellationToken cancellationToken = default)
    {
        _dbContext.SavedCards.Add(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(SavedCard card, CancellationToken cancellationToken = default)
    {
        _dbContext.SavedCards.Update(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(SavedCard card, CancellationToken cancellationToken = default)
    {
        _dbContext.SavedCards.Remove(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
