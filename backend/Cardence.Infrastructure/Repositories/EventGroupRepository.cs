using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class EventGroupRepository : IEventGroupRepository
{
    private readonly CardenceDbContext _dbContext;

    public EventGroupRepository(CardenceDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<IReadOnlyList<EventGroup>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.EventGroups
            .AsNoTracking()
            .Where(group => group.UserId == userId)
            .OrderByDescending(group => group.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<EventGroup?> GetByUserAndIdAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.EventGroups
            .FirstOrDefaultAsync(
                group => group.UserId == userId && group.Id == groupId,
                cancellationToken);
    }

    public async Task<EventGroup?> GetByUserAndNameAsync(
        Guid userId,
        string name,
        CancellationToken cancellationToken = default)
    {
        var normalized = name.Trim().ToLowerInvariant();
        return await _dbContext.EventGroups
            .FirstOrDefaultAsync(
                group => group.UserId == userId &&
                         group.Name.ToLower() == normalized,
                cancellationToken);
    }

    public async Task<int> CountCardsInGroupAsync(
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.CardEventGroups
            .CountAsync(link => link.EventGroupId == groupId, cancellationToken);
    }

    public async Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _dbContext.EventGroups
            .CountAsync(group => group.UserId == userId, cancellationToken);
    }

    public async Task AddAsync(EventGroup group, CancellationToken cancellationToken = default)
    {
        _dbContext.EventGroups.Add(group);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(EventGroup group, CancellationToken cancellationToken = default)
    {
        _dbContext.EventGroups.Update(group);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(EventGroup group, CancellationToken cancellationToken = default)
    {
        _dbContext.EventGroups.Remove(group);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task LinkCardsAsync(
        Guid userId,
        Guid groupId,
        IReadOnlyList<string> cardIds,
        CancellationToken cancellationToken = default)
    {
        if (cardIds.Count == 0)
        {
            return;
        }

        var distinctCardIds = cardIds
            .Select(cardId => cardId.Trim())
            .Where(cardId => !string.IsNullOrEmpty(cardId))
            .Distinct(StringComparer.Ordinal)
            .ToList();

        if (distinctCardIds.Count == 0)
        {
            return;
        }

        var walletCards = await _dbContext.Cards
            .Where(card =>
                card.UserId == userId &&
                card.CardRole == CardRoles.Wallet &&
                distinctCardIds.Contains(card.CardId))
            .Select(card => new { card.Id, card.CardId })
            .ToListAsync(cancellationToken);

        if (walletCards.Count == 0)
        {
            return;
        }

        var walletCardIds = walletCards.Select(card => card.Id).ToList();
        var existingLinks = await _dbContext.CardEventGroups
            .Where(link => link.EventGroupId == groupId && walletCardIds.Contains(link.CardId))
            .Select(link => link.CardId)
            .ToListAsync(cancellationToken);

        var existingSet = existingLinks.ToHashSet();
        foreach (var walletCard in walletCards)
        {
            if (existingSet.Contains(walletCard.Id))
            {
                continue;
            }

            _dbContext.CardEventGroups.Add(new CardEventGroup
            {
                CardId = walletCard.Id,
                EventGroupId = groupId,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UnlinkCardAsync(
        Guid userId,
        Guid groupId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        var walletCard = await _dbContext.Cards
            .AsNoTracking()
            .FirstOrDefaultAsync(
                card => card.UserId == userId &&
                        card.CardId == cardId.Trim() &&
                        card.CardRole == CardRoles.Wallet,
                cancellationToken);

        if (walletCard is null)
        {
            return;
        }

        var link = await _dbContext.CardEventGroups
            .FirstOrDefaultAsync(
                entry => entry.EventGroupId == groupId && entry.CardId == walletCard.Id,
                cancellationToken);

        if (link is null)
        {
            return;
        }

        _dbContext.CardEventGroups.Remove(link);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<Card>> GetCardsInGroupAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        var cards = await _dbContext.CardEventGroups
            .AsNoTracking()
            .Where(link => link.EventGroupId == groupId && link.Card.UserId == userId)
            .Select(link => link.Card)
            .Where(card => card.CardRole == CardRoles.Wallet)
            .OrderBy(card => card.SortOrder)
            .ThenByDescending(card => card.SavedAt)
            .ToListAsync(cancellationToken);

        await PopulateLinkedGroupIdsAsync(cards, cancellationToken);
        return cards;
    }

    public async Task SyncWalletCardLinksAsync(
        Guid userId,
        Guid walletCardId,
        IReadOnlyList<string> groupIds,
        CancellationToken cancellationToken = default)
    {
        var distinctGroupIds = groupIds
            .Select(groupId => groupId.Trim())
            .Where(groupId => !string.IsNullOrEmpty(groupId))
            .Distinct(StringComparer.Ordinal)
            .ToList();

        var parsedGroupIds = new List<Guid>();
        foreach (var groupId in distinctGroupIds)
        {
            if (!Guid.TryParse(groupId, out var parsed))
            {
                continue;
            }

            parsedGroupIds.Add(parsed);
        }

        var ownedGroupIds = parsedGroupIds.Count == 0
            ? []
            : await _dbContext.EventGroups
                .AsNoTracking()
                .Where(group => group.UserId == userId && parsedGroupIds.Contains(group.Id))
                .Select(group => group.Id)
                .ToListAsync(cancellationToken);

        var ownedSet = ownedGroupIds.ToHashSet();
        var existingLinks = await _dbContext.CardEventGroups
            .Where(link => link.CardId == walletCardId)
            .ToListAsync(cancellationToken);

        var toRemove = existingLinks
            .Where(link => !ownedSet.Contains(link.EventGroupId))
            .ToList();

        if (toRemove.Count > 0)
        {
            _dbContext.CardEventGroups.RemoveRange(toRemove);
        }

        var existingSet = existingLinks
            .Select(link => link.EventGroupId)
            .ToHashSet();

        foreach (var groupId in ownedSet)
        {
            if (existingSet.Contains(groupId))
            {
                continue;
            }

            _dbContext.CardEventGroups.Add(new CardEventGroup
            {
                CardId = walletCardId,
                EventGroupId = groupId,
            });
        }

        if (toRemove.Count > 0 || ownedSet.Any(groupId => !existingSet.Contains(groupId)))
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task PopulateLinkedGroupIdsAsync(
        IReadOnlyList<Card> cards,
        CancellationToken cancellationToken = default)
    {
        if (cards.Count == 0)
        {
            return;
        }

        var cardIds = cards.Select(card => card.Id).ToList();
        var links = await _dbContext.CardEventGroups
            .AsNoTracking()
            .Where(link => cardIds.Contains(link.CardId))
            .Select(link => new { link.CardId, link.EventGroupId })
            .ToListAsync(cancellationToken);

        var linkMap = links
            .GroupBy(link => link.CardId)
            .ToDictionary(
                group => group.Key,
                group => group.Select(link => link.EventGroupId.ToString()).ToList());

        foreach (var card in cards)
        {
            card.LinkedEventGroupIds = linkMap.GetValueOrDefault(card.Id) ?? [];
        }
    }
}
