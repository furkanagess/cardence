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
        return await _dbContext.SavedCardEventGroups
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

        var walletCards = await _dbContext.SavedCards
            .Where(card =>
                card.UserId == userId &&
                distinctCardIds.Contains(card.CardId))
            .Select(card => new { card.Id, card.CardId })
            .ToListAsync(cancellationToken);

        if (walletCards.Count == 0)
        {
            return;
        }

        var walletCardIds = walletCards.Select(card => card.Id).ToList();
        var existingLinks = await _dbContext.SavedCardEventGroups
            .Where(link => link.EventGroupId == groupId && walletCardIds.Contains(link.SavedCardId))
            .Select(link => link.SavedCardId)
            .ToListAsync(cancellationToken);

        var existingSet = existingLinks.ToHashSet();
        foreach (var walletCard in walletCards)
        {
            if (existingSet.Contains(walletCard.Id))
            {
                continue;
            }

            _dbContext.SavedCardEventGroups.Add(new SavedCardEventGroup
            {
                SavedCardId = walletCard.Id,
                EventGroupId = groupId,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<string>> InviteCardsByCardIdsAsync(
        Guid userId,
        Guid groupId,
        IReadOnlyList<string> cardIds,
        CancellationToken cancellationToken = default)
    {
        var distinctCardIds = NormalizeCardIds(cardIds);
        if (distinctCardIds.Count == 0)
        {
            return [];
        }

        var ownedCards = await _dbContext.Cards
            .Where(card => distinctCardIds.Contains(card.CardId))
            .ToListAsync(cancellationToken);

        var foundCardIds = ownedCards
            .Select(card => card.CardId)
            .ToHashSet(StringComparer.Ordinal);
        var invalidCardIds = distinctCardIds
            .Where(cardId => !foundCardIds.Contains(cardId))
            .ToList();

        if (ownedCards.Count == 0)
        {
            return invalidCardIds;
        }

        var existingSavedCards = await _dbContext.SavedCards
            .Where(card => card.UserId == userId && foundCardIds.Contains(card.CardId))
            .ToListAsync(cancellationToken);

        var savedByCardId = existingSavedCards
            .ToDictionary(card => card.CardId, StringComparer.Ordinal);
        var nextSortOrder = await _dbContext.SavedCards
            .CountAsync(card => card.UserId == userId, cancellationToken);
        var now = DateTime.UtcNow;

        foreach (var ownedCard in ownedCards)
        {
            if (savedByCardId.ContainsKey(ownedCard.CardId))
            {
                continue;
            }

            var savedCard = CreateSavedCardFromBusinessCard(
                userId,
                ownedCard,
                nextSortOrder++,
                now);
            _dbContext.SavedCards.Add(savedCard);
            savedByCardId[ownedCard.CardId] = savedCard;

            if (ownedCard.UserId != userId)
            {
                ownedCard.SaveCount += 1;
                _dbContext.CardInteractions.Add(new CardInteraction
                {
                    Id = Guid.NewGuid(),
                    ActorUserId = userId,
                    TargetCardEntityId = ownedCard.Id,
                    TargetCardPublicId = ownedCard.CardId,
                    EventType = CardInteractionTypes.CardSaved,
                    Source = CardCreationMethods.CardenceLink,
                    OccurredAt = now,
                });
            }
        }

        var savedCardIds = savedByCardId.Values.Select(card => card.Id).ToList();
        var existingLinks = await _dbContext.SavedCardEventGroups
            .Where(link => link.EventGroupId == groupId && savedCardIds.Contains(link.SavedCardId))
            .Select(link => link.SavedCardId)
            .ToListAsync(cancellationToken);
        var existingLinkSet = existingLinks.ToHashSet();

        foreach (var savedCard in savedByCardId.Values)
        {
            if (existingLinkSet.Contains(savedCard.Id))
            {
                continue;
            }

            _dbContext.SavedCardEventGroups.Add(new SavedCardEventGroup
            {
                SavedCardId = savedCard.Id,
                EventGroupId = groupId,
            });
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        return invalidCardIds;
    }

    public async Task UnlinkCardAsync(
        Guid userId,
        Guid groupId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        var walletCard = await _dbContext.SavedCards
            .AsNoTracking()
            .FirstOrDefaultAsync(
                card => card.UserId == userId && card.CardId == cardId.Trim(),
                cancellationToken);

        if (walletCard is null)
        {
            return;
        }

        var link = await _dbContext.SavedCardEventGroups
            .FirstOrDefaultAsync(
                entry => entry.EventGroupId == groupId && entry.SavedCardId == walletCard.Id,
                cancellationToken);

        if (link is null)
        {
            return;
        }

        _dbContext.SavedCardEventGroups.Remove(link);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<SavedCard>> GetCardsInGroupAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        var cards = await _dbContext.SavedCardEventGroups
            .AsNoTracking()
            .Where(link => link.EventGroupId == groupId && link.SavedCard.UserId == userId)
            .Select(link => link.SavedCard)
            .OrderByDescending(card => card.IsOwnerPremium)
            .ThenBy(card => card.SortOrder)
            .ThenByDescending(card => card.SavedAt)
            .ToListAsync(cancellationToken);

        await PopulateLinkedGroupIdsAsync(cards, cancellationToken);
        return cards;
    }

    public async Task SyncWalletCardLinksAsync(
        Guid userId,
        Guid savedCardId,
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
        var existingLinks = await _dbContext.SavedCardEventGroups
            .Where(link => link.SavedCardId == savedCardId)
            .ToListAsync(cancellationToken);

        var toRemove = existingLinks
            .Where(link => !ownedSet.Contains(link.EventGroupId))
            .ToList();

        if (toRemove.Count > 0)
        {
            _dbContext.SavedCardEventGroups.RemoveRange(toRemove);
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

            _dbContext.SavedCardEventGroups.Add(new SavedCardEventGroup
            {
                SavedCardId = savedCardId,
                EventGroupId = groupId,
            });
        }

        if (toRemove.Count > 0 || ownedSet.Any(groupId => !existingSet.Contains(groupId)))
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task PopulateLinkedGroupIdsAsync(
        IReadOnlyList<SavedCard> cards,
        CancellationToken cancellationToken = default)
    {
        if (cards.Count == 0)
        {
            return;
        }

        var cardIds = cards.Select(card => card.Id).ToList();
        var links = await _dbContext.SavedCardEventGroups
            .AsNoTracking()
            .Where(link => cardIds.Contains(link.SavedCardId))
            .Select(link => new { link.SavedCardId, link.EventGroupId })
            .ToListAsync(cancellationToken);

        var linkMap = links
            .GroupBy(link => link.SavedCardId)
            .ToDictionary(
                group => group.Key,
                group => group.Select(link => link.EventGroupId.ToString()).ToList());

        foreach (var card in cards)
        {
            card.LinkedEventGroupIds = linkMap.GetValueOrDefault(card.Id) ?? [];
        }
    }

    private static List<string> NormalizeCardIds(IReadOnlyList<string> cardIds)
    {
        return cardIds
            .Select(cardId => cardId.Trim())
            .Where(cardId => !string.IsNullOrEmpty(cardId))
            .Distinct(StringComparer.Ordinal)
            .ToList();
    }

    private static SavedCard CreateSavedCardFromBusinessCard(
        Guid userId,
        Card card,
        int sortOrder,
        DateTime now)
    {
        return new SavedCard
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CardId = card.CardId,
            CreationMethod = CardCreationMethods.CardenceLink,
            DisplayName = card.DisplayName,
            Email = card.Email,
            Phone = card.Phone,
            Company = card.Company,
            Title = card.Title,
            Website = card.Website,
            Linkedin = card.Linkedin,
            Skills = card.Skills,
            School = card.School,
            About = card.About,
            Address = card.Address,
            City = card.City,
            Country = card.Country,
            Department = card.Department,
            AttendedEvents = card.AttendedEvents,
            Twitter = card.Twitter,
            Instagram = card.Instagram,
            Birthday = card.Birthday,
            PhotoUrl = card.PhotoUrl,
            AccentColor = card.AccentColor,
            BackgroundColor = card.BackgroundColor,
            SavedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            SortOrder = sortOrder,
            IsOwnerPremium = card.IsOwnerPremium,
            CreatedAt = now,
            UpdatedAt = now,
        };
    }
}
