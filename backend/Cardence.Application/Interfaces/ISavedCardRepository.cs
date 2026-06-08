using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface ISavedCardRepository
{
    Task<IReadOnlyList<SavedCard>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<SavedCard?> GetByUserAndCardIdAsync(
        Guid userId,
        string cardId,
        CancellationToken cancellationToken = default);

    Task<int> CountByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task AddAsync(SavedCard card, CancellationToken cancellationToken = default);

    Task UpdateAsync(SavedCard card, CancellationToken cancellationToken = default);

    Task DeleteAsync(SavedCard card, CancellationToken cancellationToken = default);
}
