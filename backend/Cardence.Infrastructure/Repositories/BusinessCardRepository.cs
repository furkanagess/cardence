using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
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

    public async Task<IReadOnlyList<Card>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Cards
            .AsNoTracking()
            .Where(card => card.UserId == userId && card.CardRole == CardRoles.Own)
            .OrderByDescending(card => card.UpdatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<Card?> GetByUserAndCardIdAsync(
        Guid userId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Cards
            .FirstOrDefaultAsync(
                card => card.UserId == userId &&
                        card.CardId == cardId &&
                        card.CardRole == CardRoles.Own,
                cancellationToken);
    }

    public async Task<Card?> GetByCardIdAsync(
        string cardId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Cards
            .AsNoTracking()
            .FirstOrDefaultAsync(
                card => card.CardId == cardId && card.CardRole == CardRoles.Own,
                cancellationToken);
    }

    public async Task<bool> CardIdExistsAsync(
        string cardId,
        Guid? excludeId = null,
        CancellationToken cancellationToken = default)
    {
        var query = _dbContext.Cards.Where(
            card => card.CardId == cardId && card.CardRole == CardRoles.Own);
        if (excludeId.HasValue)
        {
            query = query.Where(card => card.Id != excludeId.Value);
        }

        return await query.AnyAsync(cancellationToken);
    }

    public async Task AddAsync(Card card, CancellationToken cancellationToken = default)
    {
        _dbContext.Cards.Add(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Card card, CancellationToken cancellationToken = default)
    {
        _dbContext.Cards.Update(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Card card, CancellationToken cancellationToken = default)
    {
        _dbContext.Cards.Remove(card);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task IncrementSaveCountAsync(
        Guid ownCardId,
        CancellationToken cancellationToken = default)
    {
        await _dbContext.Cards
            .Where(card => card.Id == ownCardId && card.CardRole == CardRoles.Own)
            .ExecuteUpdateAsync(
                setters => setters.SetProperty(
                    card => card.SaveCount,
                    card => card.SaveCount + 1),
                cancellationToken);
    }

    public async Task<int> SumSaveCountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Cards
            .AsNoTracking()
            .Where(card => card.UserId == userId && card.CardRole == CardRoles.Own)
            .SumAsync(card => card.SaveCount, cancellationToken);
    }

    public async Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Cards
            .AsNoTracking()
            .CountAsync(
                card => card.UserId == userId && card.CardRole == CardRoles.Own,
                cancellationToken);
    }
}
