using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using Cardence.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;

namespace Cardence.Infrastructure.Repositories;

public sealed class CardInteractionRepository(CardenceDbContext db) : ICardInteractionRepository
{
    public async Task AddAsync(CardInteraction interaction, CancellationToken cancellationToken = default)
    {
        db.CardInteractions.Add(interaction);
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CardInteraction>> GetByTargetCardPublicIdAsync(
        string targetCardPublicId,
        CancellationToken cancellationToken = default)
    {
        return await db.CardInteractions
            .AsNoTracking()
            .Where(x => x.TargetCardPublicId == targetCardPublicId)
            .OrderByDescending(x => x.OccurredAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<CardInteraction>> GetByTargetCardEntityIdsAsync(
        IReadOnlyCollection<Guid> targetCardEntityIds,
        CancellationToken cancellationToken = default)
    {
        if (targetCardEntityIds.Count == 0)
        {
            return [];
        }

        return await db.CardInteractions
            .AsNoTracking()
            .Where(x => targetCardEntityIds.Contains(x.TargetCardEntityId))
            .OrderByDescending(x => x.OccurredAt)
            .ToListAsync(cancellationToken);
    }
}
