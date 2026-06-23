using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class SavedCardRepository : ISavedCardRepository
{
    private readonly CardenceDbContext _dbContext;
    private readonly IEventGroupRepository _eventGroupRepository;

    public SavedCardRepository(
        CardenceDbContext dbContext,
        IEventGroupRepository eventGroupRepository)
    {
        _dbContext = dbContext;
        _eventGroupRepository = eventGroupRepository;
    }

    public async Task<IReadOnlyList<Card>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var cards = await _dbContext.Cards
            .AsNoTracking()
            .Where(card => card.UserId == userId && card.CardRole == CardRoles.Wallet)
            .OrderBy(card => card.SortOrder)
            .ThenByDescending(card => card.SavedAt)
            .ToListAsync(cancellationToken);

        await _eventGroupRepository.PopulateLinkedGroupIdsAsync(cards, cancellationToken);
        return cards;
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
                        card.CardRole == CardRoles.Wallet,
                cancellationToken);
    }

    public async Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Cards
            .CountAsync(
                card => card.UserId == userId && card.CardRole == CardRoles.Wallet,
                cancellationToken);
    }

    public async Task<int> CountManualByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.Cards
            .CountAsync(
                card => card.UserId == userId &&
                        card.CardRole == CardRoles.Wallet &&
                        (card.CreationMethod == CardCreationMethods.Manual ||
                         card.CreationMethod == CardCreationMethods.PhotoScan),
                cancellationToken);
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
}
