using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface ISavedCardRepository
{
    Task<IReadOnlyList<Card>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<Card?> GetByUserAndCardIdAsync(
        Guid userId,
        string cardId,
        CancellationToken cancellationToken = default);

    Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<int> CountManualByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task AddAsync(Card card, CancellationToken cancellationToken = default);

    Task UpdateAsync(Card card, CancellationToken cancellationToken = default);

    Task DeleteAsync(Card card, CancellationToken cancellationToken = default);
}
