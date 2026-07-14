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
        return await _dbContext.EventGroupWalletCards
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
        var user = await _dbContext.Users
            .FirstOrDefaultAsync(entry => entry.Id == userId, cancellationToken);
        if (user is null)
        {
            return;
        }

        var ids = user.SavedCardIds
            .Where(id => !string.IsNullOrWhiteSpace(id))
            .Select(id => id.Trim())
            .Distinct(StringComparer.Ordinal)
            .ToList();
        if (!ids.Contains(ownedCard.CardId, StringComparer.Ordinal))
        {
            ids.Add(ownedCard.CardId);
            user.SavedCardIds = ids;
            user.UpdatedAt = now;
            if (ownedCard.UserId != userId)
            {
                ownedCard.SaveCount += 1;
            }
        }

        var alreadyLinked = await _dbContext.EventGroupWalletCards
            .AnyAsync(
                link =>
                    link.EventGroupId == groupId &&
                    link.UserId == userId &&
                    link.CardId == ownedCard.CardId,
                cancellationToken);
        if (alreadyLinked)
        {
            return;
        }

        _dbContext.EventGroupWalletCards.Add(new EventGroupWalletCard
        {
            UserId = userId,
            CardId = ownedCard.CardId,
            EventGroupId = groupId,
        });
    }

    public async Task UnlinkCardAsync(
        Guid userId,
        Guid groupId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        var normalizedCardId = cardId.Trim();
        var link = await _dbContext.EventGroupWalletCards
            .FirstOrDefaultAsync(
                entry =>
                    entry.EventGroupId == groupId &&
                    entry.UserId == userId &&
                    entry.CardId == normalizedCardId,
                cancellationToken);

        if (link is null)
        {
            return;
        }

        _dbContext.EventGroupWalletCards.Remove(link);
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<SavedCard>> GetCardsInGroupAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        var linkedCardIds = await _dbContext.EventGroupWalletCards
            .AsNoTracking()
            .Where(link => link.EventGroupId == groupId && link.UserId == userId)
            .Select(link => link.CardId)
            .ToListAsync(cancellationToken);
        if (linkedCardIds.Count == 0)
        {
            return [];
        }

        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(entry => entry.Id == userId, cancellationToken);
        if (user is null)
        {
            return [];
        }

        var cards = await _dbContext.Cards
            .AsNoTracking()
            .Where(card => linkedCardIds.Contains(card.CardId))
            .ToListAsync(cancellationToken);

        var projected = cards
            .Select(card =>
            {
                user.SavedCardNotes.TryGetValue(card.CardId, out var note);
                return new SavedCard
                {
                    UserId = userId,
                    CardId = card.CardId,
                    CreationMethod = card.IsWalletContact
                        ? CardCreationMethods.Manual
                        : CardCreationMethods.CardenceLink,
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
                    Note = note,
                    PhotoUrl = card.PhotoUrl,
                    AccentColor = card.AccentColor,
                    BackgroundColor = card.BackgroundColor,
                    SavedAt = new DateTimeOffset(card.CreatedAt, TimeSpan.Zero).ToUnixTimeMilliseconds(),
                    IsOwnerPremium = card.IsOwnerPremium,
                    IsWalletContact = card.IsWalletContact,
                    CreatedAt = card.CreatedAt,
                    UpdatedAt = card.UpdatedAt,
                };
            })
            .OrderByDescending(card => card.IsOwnerPremium)
            .ThenBy(card => card.CardId)
            .ToList();

        await PopulateLinkedGroupIdsAsync(projected, cancellationToken);
        return projected;
    }

    public async Task SyncWalletCardLinksAsync(
        Guid userId,
        string cardId,
        IReadOnlyList<string> groupIds,
        CancellationToken cancellationToken = default)
    {
        var normalizedCardId = cardId.Trim();
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
        var existingLinks = await _dbContext.EventGroupWalletCards
            .Where(link => link.UserId == userId && link.CardId == normalizedCardId)
            .ToListAsync(cancellationToken);

        var toRemove = existingLinks
            .Where(link => !ownedSet.Contains(link.EventGroupId))
            .ToList();

        if (toRemove.Count > 0)
        {
            _dbContext.EventGroupWalletCards.RemoveRange(toRemove);
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

        var userId = cards[0].UserId;
        var cardIds = cards.Select(card => card.CardId).Distinct(StringComparer.Ordinal).ToList();
        var links = await _dbContext.EventGroupWalletCards
            .AsNoTracking()
            .Where(link => link.UserId == userId && cardIds.Contains(link.CardId))
            .Select(link => new { link.CardId, link.EventGroupId })
            .ToListAsync(cancellationToken);

        var linkMap = links
            .GroupBy(link => link.CardId, StringComparer.Ordinal)
            .ToDictionary(
                group => group.Key,
                group => group.Select(link => link.EventGroupId.ToString()).ToList(),
                StringComparer.Ordinal);

        foreach (var card in cards)
        {
            card.LinkedEventGroupIds = linkMap.GetValueOrDefault(card.CardId) ?? [];
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
}
