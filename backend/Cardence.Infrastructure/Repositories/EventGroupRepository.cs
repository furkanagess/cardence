using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Application.DTOs.EventGroups;
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
        // Doğrudan üyelik yasak; eski istemciler için davet akışına yönlendirilir.
        await InviteCardsByCardIdsAsync(userId, groupId, cardIds, cancellationToken);
    }

    public async Task<EventGroupInviteCardsResult> InviteCardsByCardIdsAsync(
        Guid userId,
        Guid groupId,
        IReadOnlyList<string> cardIds,
        CancellationToken cancellationToken = default)
    {
        var distinctCardIds = NormalizeCardIds(cardIds);
        if (distinctCardIds.Count == 0)
        {
            return new EventGroupInviteCardsResult();
        }

        await DeleteExpiredInvitationsAsync(cancellationToken);

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
            return new EventGroupInviteCardsResult
            {
                InvalidCardIds = invalidCardIds,
            };
        }

        var now = DateTime.UtcNow;
        var newInvites = new List<CreatedEventGroupInvite>();
        foreach (var ownedCard in ownedCards)
        {
            if (ownedCard.UserId == userId)
            {
                await EnsureBusinessCardLinkedToGroupAsync(
                    userId,
                    groupId,
                    ownedCard,
                    now,
                    cancellationToken);
                continue;
            }

            var createdInvite = await CreatePendingInviteIfNeededAsync(
                userId,
                groupId,
                ownedCard,
                now,
                cancellationToken);
            if (createdInvite is not null)
            {
                newInvites.Add(createdInvite);
            }
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
        return new EventGroupInviteCardsResult
        {
            InvalidCardIds = invalidCardIds,
            NewInvites = newInvites,
        };
    }

    public async Task<IReadOnlyList<EventGroupCardInvite>> GetPendingInvitationsForInviteeAsync(
        Guid inviteeUserId,
        CancellationToken cancellationToken = default)
    {
        await DeleteExpiredInvitationsAsync(cancellationToken);

        var now = DateTime.UtcNow;
        return await _dbContext.EventGroupCardInvites
            .AsNoTracking()
            .Include(invite => invite.EventGroup)
            .Include(invite => invite.InviterUser)
            .Include(invite => invite.Card)
            .Where(invite =>
                invite.InviteeUserId == inviteeUserId &&
                invite.Status == EventGroupInvitationStatuses.Pending &&
                invite.ExpiresAtUtc > now)
            .OrderByDescending(invite => invite.CreatedAtUtc)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<EventGroupCardInvite>> GetOutboundInvitationsForGroupAsync(
        Guid ownerUserId,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        await DeleteExpiredInvitationsAsync(cancellationToken);

        var ownsGroup = await _dbContext.EventGroups
            .AsNoTracking()
            .AnyAsync(
                group => group.Id == groupId && group.UserId == ownerUserId,
                cancellationToken);
        if (!ownsGroup)
        {
            return [];
        }

        return await _dbContext.EventGroupCardInvites
            .AsNoTracking()
            .Include(invite => invite.InviteeUser)
            .Include(invite => invite.Card)
            .Where(invite => invite.EventGroupId == groupId)
            .OrderByDescending(invite => invite.CreatedAtUtc)
            .ToListAsync(cancellationToken);
    }

    public async Task<EventGroupCardInvite?> GetInvitationForInviteeAsync(
        Guid inviteeUserId,
        Guid invitationId,
        CancellationToken cancellationToken = default)
    {
        await DeleteExpiredInvitationsAsync(cancellationToken);

        var now = DateTime.UtcNow;
        return await _dbContext.EventGroupCardInvites
            .Include(invite => invite.EventGroup)
            .Include(invite => invite.InviterUser)
            .Include(invite => invite.Card)
            .FirstOrDefaultAsync(
                invite =>
                    invite.Id == invitationId &&
                    invite.InviteeUserId == inviteeUserId &&
                    invite.ExpiresAtUtc > now,
                cancellationToken);
    }

    public async Task AcceptInvitationAsync(
        EventGroupCardInvite invitation,
        CancellationToken cancellationToken = default)
    {
        if (invitation.Status != EventGroupInvitationStatuses.Pending ||
            EventGroupInvitationPolicy.IsExpired(invitation.ExpiresAtUtc))
        {
            return;
        }

        var now = DateTime.UtcNow;
        await EnsureBusinessCardLinkedToGroupAsync(
            invitation.InviterUserId,
            invitation.EventGroupId,
            invitation.Card,
            now,
            cancellationToken);

        invitation.Status = EventGroupInvitationStatuses.Accepted;
        invitation.RespondedAtUtc = now;
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task RejectInvitationAsync(
        EventGroupCardInvite invitation,
        CancellationToken cancellationToken = default)
    {
        if (invitation.Status != EventGroupInvitationStatuses.Pending ||
            EventGroupInvitationPolicy.IsExpired(invitation.ExpiresAtUtc))
        {
            return;
        }

        invitation.Status = EventGroupInvitationStatuses.Rejected;
        invitation.RespondedAtUtc = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteExpiredInvitationsAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        await _dbContext.EventGroupCardInvites
            .Where(invite => invite.ExpiresAtUtc <= now)
            .ExecuteDeleteAsync(cancellationToken);
    }

    private async Task<CreatedEventGroupInvite?> CreatePendingInviteIfNeededAsync(
        Guid inviterUserId,
        Guid groupId,
        Card ownedCard,
        DateTime now,
        CancellationToken cancellationToken)
    {
        var existingInvite = await _dbContext.EventGroupCardInvites
            .Where(invite =>
                invite.EventGroupId == groupId &&
                invite.CardEntityId == ownedCard.Id)
            .OrderByDescending(invite => invite.CreatedAtUtc)
            .FirstOrDefaultAsync(cancellationToken);

        if (existingInvite is not null)
        {
            if (EventGroupInvitationPolicy.IsExpired(existingInvite.ExpiresAtUtc, now))
            {
                _dbContext.EventGroupCardInvites.Remove(existingInvite);
            }
            else if (existingInvite.Status == EventGroupInvitationStatuses.Pending ||
                     existingInvite.Status == EventGroupInvitationStatuses.Accepted)
            {
                return null;
            }
        }

        var invitationId = Guid.NewGuid();
        _dbContext.EventGroupCardInvites.Add(new EventGroupCardInvite
        {
            Id = invitationId,
            EventGroupId = groupId,
            InviterUserId = inviterUserId,
            InviteeUserId = ownedCard.UserId,
            CardEntityId = ownedCard.Id,
            CardId = ownedCard.CardId,
            Status = EventGroupInvitationStatuses.Pending,
            CreatedAtUtc = now,
            ExpiresAtUtc = EventGroupInvitationPolicy.ComputeExpiresAtUtc(now),
        });

        return new CreatedEventGroupInvite
        {
            InvitationId = invitationId,
            InviteeUserId = ownedCard.UserId,
            InviterUserId = inviterUserId,
            EventGroupId = groupId,
            CardId = ownedCard.CardId,
        };
    }

    private async Task EnsureBusinessCardLinkedToGroupAsync(
        Guid userId,
        Guid groupId,
        Card ownedCard,
        DateTime now,
        CancellationToken cancellationToken)
    {
        var savedCard = await _dbContext.SavedCards
            .FirstOrDefaultAsync(
                card => card.UserId == userId && card.CardId == ownedCard.CardId,
                cancellationToken);

        if (savedCard is null)
        {
            var nextSortOrder = await _dbContext.SavedCards
                .CountAsync(card => card.UserId == userId, cancellationToken);
            savedCard = CreateSavedCardFromBusinessCard(
                userId,
                ownedCard,
                nextSortOrder,
                now);
            _dbContext.SavedCards.Add(savedCard);

            if (ownedCard.UserId != userId)
            {
                ownedCard.SaveCount += 1;
            }
        }

        var alreadyLinked = await _dbContext.SavedCardEventGroups
            .AnyAsync(
                link => link.EventGroupId == groupId && link.SavedCardId == savedCard.Id,
                cancellationToken);
        if (alreadyLinked)
        {
            return;
        }

        _dbContext.SavedCardEventGroups.Add(new SavedCardEventGroup
        {
            SavedCardId = savedCard.Id,
            EventGroupId = groupId,
        });
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
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        // Yeni grup üyeliği yalnızca davet kabulüyle eklenir; SaveSavedCard
        // üzerinden linkedEventGroupIds ile doğrudan ekleme yapılmaz.
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
