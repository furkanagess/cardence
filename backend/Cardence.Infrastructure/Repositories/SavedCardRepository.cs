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

    public async Task<IReadOnlyList<SavedCard>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var cards = await _dbContext.SavedCards
            .AsNoTracking()
            .Where(card => card.UserId == userId)
            .OrderByDescending(card => card.IsOwnerPremium)
            .ThenBy(card => card.SortOrder)
            .ThenByDescending(card => card.SavedAt)
            .ToListAsync(cancellationToken);

        await _eventGroupRepository.PopulateLinkedGroupIdsAsync(cards, cancellationToken);
        return cards;
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

    public async Task<int> CountManualByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.SavedCards
            .CountAsync(
                card => card.UserId == userId &&
                        (card.CreationMethod == CardCreationMethods.Manual ||
                         card.CreationMethod == CardCreationMethods.PhotoScan),
                cancellationToken);
    }

    public async Task<IReadOnlyList<SavedCard>> GetByTargetCardPublicIdsAsync(
        IReadOnlyCollection<string> cardPublicIds,
        CancellationToken cancellationToken = default)
    {
        if (cardPublicIds.Count == 0)
        {
            return [];
        }

        var normalizedIds = cardPublicIds
            .Where(id => !string.IsNullOrWhiteSpace(id))
            .Select(id => id.Trim())
            .Distinct(StringComparer.Ordinal)
            .ToList();

        if (normalizedIds.Count == 0)
        {
            return [];
        }

        return await _dbContext.SavedCards
            .AsNoTracking()
            .Where(card => normalizedIds.Contains(card.CardId))
            .OrderByDescending(card => card.SavedAt)
            .ToListAsync(cancellationToken);
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

    public async Task SetOwnerPremiumByCardIdsAsync(
        IReadOnlyList<string> cardIds,
        bool isOwnerPremium,
        CancellationToken cancellationToken = default)
    {
        if (cardIds.Count == 0)
        {
            return;
        }

        await _dbContext.SavedCards
            .Where(card => cardIds.Contains(card.CardId))
            .ExecuteUpdateAsync(
                setters => setters.SetProperty(
                    card => card.IsOwnerPremium,
                    isOwnerPremium),
                cancellationToken);
    }

    public async Task ReconcileOwnerPremiumWithCardsAsync(
        CancellationToken cancellationToken = default)
    {
        await _dbContext.Database.ExecuteSqlRawAsync(
            """
            UPDATE saved_cards AS sc
            SET is_owner_premium = c.is_owner_premium
            FROM cards AS c
            WHERE sc.card_id = c.card_id
              AND sc.is_owner_premium IS DISTINCT FROM c.is_owner_premium;
            """,
            cancellationToken);
    }
}
