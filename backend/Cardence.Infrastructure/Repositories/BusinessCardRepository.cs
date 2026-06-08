using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class BusinessCardRepository : IBusinessCardRepository
{
    private readonly CardenceDbContext _dbContext;

    public BusinessCardRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<BusinessCard>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.BusinessCards
            .AsNoTracking()
            .Where(card => card.UserId == userId)
            .OrderByDescending(card => card.UpdatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<BusinessCard?> GetByUserAndCardIdAsync(
        Guid userId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.BusinessCards
            .FirstOrDefaultAsync(card => card.UserId == userId && card.CardId == cardId, cancellationToken);
    }

    public async Task<BusinessCard?> GetByCardIdAsync(
        string cardId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.BusinessCards
            .AsNoTracking()
            .FirstOrDefaultAsync(card => card.CardId == cardId, cancellationToken);
    }

    public async Task<bool> CardIdExistsAsync(
        string cardId,
        Guid? excludeId = null,
        CancellationToken cancellationToken = default)
    {
        var query = _dbContext.BusinessCards.Where(card => card.CardId == cardId);
        if (excludeId.HasValue)
        {
            query = query.Where(card => card.Id != excludeId.Value);
        }

        return await query.AnyAsync(cancellationToken);
    }

    public async Task AddAsync(BusinessCard card, CancellationToken cancellationToken = default)
    {
        _dbContext.BusinessCards.Add(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(BusinessCard card, CancellationToken cancellationToken = default)
    {
        _dbContext.BusinessCards.Update(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(BusinessCard card, CancellationToken cancellationToken = default)
    {
        _dbContext.BusinessCards.Remove(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }
}
