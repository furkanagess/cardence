using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface ICardInteractionRepository
{
    Task AddAsync(CardInteraction interaction, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<CardInteraction>> GetByTargetCardPublicIdAsync(
        string targetCardPublicId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<CardInteraction>> GetByTargetCardEntityIdsAsync(
        IReadOnlyCollection<Guid> targetCardEntityIds,
        CancellationToken cancellationToken = default);
}
