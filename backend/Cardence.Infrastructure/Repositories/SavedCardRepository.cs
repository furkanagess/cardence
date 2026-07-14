using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using WalletIds = Cardence.Domain.Constants.WalletConstants;

namespace Cardence.Infrastructure.Repositories;

/// <summary>
/// Cüzdan üyeliği users.saved_card_ids üzerinden; kart verisi cards tablosundan çözülür.
/// </summary>
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
        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(entry => entry.Id == userId, cancellationToken);
        if (user is null || user.SavedCardIds.Count == 0)
        {
            return [];
        }

        var orderedIds = DeduplicatePreserveOrder(user.SavedCardIds);
        return await ProjectAsync(user, orderedIds, cancellationToken);
    }

    public async Task<SavedCard?> GetByUserAndCardIdAsync(
        Guid userId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(entry => entry.Id == userId, cancellationToken);
        if (user is null)
        {
            return null;
        }

        if (!user.SavedCardIds.Contains(cardId, StringComparer.Ordinal))
        {
            return null;
        }

        var projected = await ProjectAsync(user, [cardId], cancellationToken);
        return projected.FirstOrDefault();
    }

    public async Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var user = await _dbContext.Users
            .AsNoTracking()
            .FirstOrDefaultAsync(entry => entry.Id == userId, cancellationToken);
        if (user is null)
        {
            return 0;
        }

        return DeduplicatePreserveOrder(user.SavedCardIds).Count;
    }

    public async Task<int> CountManualByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var cards = await GetByUserIdAsync(userId, cancellationToken);
        return cards.Count(card => WalletIds.IsManualWalletCardId(card.CardId));
    }

    public async Task<IReadOnlyList<SavedCard>> GetByTargetCardPublicIdsAsync(
        IReadOnlyCollection<string> cardPublicIds,
        CancellationToken cancellationToken = default)
    {
        if (cardPublicIds.Count == 0)
        {
            return [];
        }

        var targets = cardPublicIds
            .Where(id => !string.IsNullOrWhiteSpace(id))
            .Select(id => id.Trim())
            .Distinct(StringComparer.Ordinal)
            .ToList();
        if (targets.Count == 0)
        {
            return [];
        }

        // jsonb listesini sunucuda filtrelemek için kullanıcıları bellekte tarıyoruz.
        var users = await _dbContext.Users
            .AsNoTracking()
            .Where(user => user.SavedCardIds.Count > 0)
            .ToListAsync(cancellationToken);

        var results = new List<SavedCard>();
        foreach (var user in users)
        {
            var matched = DeduplicatePreserveOrder(user.SavedCardIds)
                .Where(id => targets.Contains(id, StringComparer.Ordinal))
                .ToList();
            if (matched.Count == 0)
            {
                continue;
            }

            results.AddRange(await ProjectAsync(user, matched, cancellationToken));
        }

        return results;
    }

    public async Task AddAsync(SavedCard card, CancellationToken cancellationToken = default)
    {
        var user = await _dbContext.Users
            .FirstOrDefaultAsync(entry => entry.Id == card.UserId, cancellationToken)
            ?? throw new InvalidOperationException("User not found for wallet add.");

        var ids = DeduplicatePreserveOrder(user.SavedCardIds);
        if (ids.Contains(card.CardId, StringComparer.Ordinal))
        {
            return;
        }

        ids.Add(card.CardId);
        user.SavedCardIds = ids;
        if (!string.IsNullOrWhiteSpace(card.Note))
        {
            user.SavedCardNotes[card.CardId] = card.Note.Trim();
        }

        user.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(SavedCard card, CancellationToken cancellationToken = default)
    {
        var user = await _dbContext.Users
            .FirstOrDefaultAsync(entry => entry.Id == card.UserId, cancellationToken)
            ?? throw new InvalidOperationException("User not found for wallet update.");

        if (!user.SavedCardIds.Contains(card.CardId, StringComparer.Ordinal))
        {
            return;
        }

        if (string.IsNullOrWhiteSpace(card.Note))
        {
            user.SavedCardNotes.Remove(card.CardId);
        }
        else
        {
            user.SavedCardNotes[card.CardId] = card.Note.Trim();
        }

        user.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(SavedCard card, CancellationToken cancellationToken = default)
    {
        var user = await _dbContext.Users
            .FirstOrDefaultAsync(entry => entry.Id == card.UserId, cancellationToken);
        if (user is null)
        {
            return;
        }

        var ids = DeduplicatePreserveOrder(user.SavedCardIds);
        ids.RemoveAll(id => string.Equals(id, card.CardId, StringComparison.Ordinal));
        user.SavedCardIds = ids;
        user.SavedCardNotes.Remove(card.CardId);
        user.UpdatedAt = DateTime.UtcNow;

        var links = await _dbContext.EventGroupWalletCards
            .Where(link => link.UserId == card.UserId && link.CardId == card.CardId)
            .ToListAsync(cancellationToken);
        if (links.Count > 0)
        {
            _dbContext.EventGroupWalletCards.RemoveRange(links);
        }

        var walletContact = await _dbContext.Cards
            .FirstOrDefaultAsync(
                entry =>
                    entry.UserId == card.UserId &&
                    entry.CardId == card.CardId &&
                    entry.IsWalletContact,
                cancellationToken);
        if (walletContact is not null)
        {
            _dbContext.Cards.Remove(walletContact);
        }

        await _dbContext.SaveChangesAsync(cancellationToken);
    }

    public Task SetOwnerPremiumByCardIdsAsync(
        IReadOnlyList<string> cardIds,
        bool isOwnerPremium,
        CancellationToken cancellationToken = default)
    {
        // Premium bayrağı artık cards.is_owner_premium üzerinden gelir.
        return Task.CompletedTask;
    }

    public Task ReconcileOwnerPremiumWithCardsAsync(
        CancellationToken cancellationToken = default)
    {
        return Task.CompletedTask;
    }

    private async Task<IReadOnlyList<SavedCard>> ProjectAsync(
        User user,
        IReadOnlyList<string> orderedIds,
        CancellationToken cancellationToken)
    {
        if (orderedIds.Count == 0)
        {
            return [];
        }

        var cards = await _dbContext.Cards
            .AsNoTracking()
            .Where(card => orderedIds.Contains(card.CardId))
            .ToListAsync(cancellationToken);
        var byId = cards.ToDictionary(card => card.CardId, StringComparer.Ordinal);

        var projected = new List<SavedCard>(orderedIds.Count);
        for (var index = 0; index < orderedIds.Count; index++)
        {
            var cardId = orderedIds[index];
            if (!byId.TryGetValue(cardId, out var card))
            {
                continue;
            }

            user.SavedCardNotes.TryGetValue(cardId, out var note);
            projected.Add(FromCard(user.Id, card, note, sortOrder: index));
        }

        return projected;
    }

    private static SavedCard FromCard(
        Guid userId,
        Card card,
        string? note,
        int sortOrder)
    {
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
            SortOrder = sortOrder,
            IsOwnerPremium = card.IsOwnerPremium,
            IsWalletContact = card.IsWalletContact,
            CreatedAt = card.CreatedAt,
            UpdatedAt = card.UpdatedAt,
        };
    }

    private static List<string> DeduplicatePreserveOrder(IEnumerable<string> ids)
    {
        var result = new List<string>();
        var seen = new HashSet<string>(StringComparer.Ordinal);
        foreach (var raw in ids)
        {
            var id = raw?.Trim();
            if (string.IsNullOrEmpty(id) || !seen.Add(id))
            {
                continue;
            }

            result.Add(id);
        }

        return result;
    }
}
