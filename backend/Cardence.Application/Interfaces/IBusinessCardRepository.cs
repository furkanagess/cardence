using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IBusinessCardRepository
{
    Task<IReadOnlyList<Card>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<Card?> GetByUserAndCardIdAsync(Guid userId, string cardId, CancellationToken cancellationToken = default);
    Task<Card?> GetByCardIdAsync(string cardId, CancellationToken cancellationToken = default);
    Task<bool> CardIdExistsAsync(string cardId, Guid? excludeId = null, CancellationToken cancellationToken = default);
    Task AddAsync(Card card, CancellationToken cancellationToken = default);
    Task UpdateAsync(Card card, CancellationToken cancellationToken = default);
    Task DeleteAsync(Card card, CancellationToken cancellationToken = default);
    Task IncrementSaveCountAsync(Guid ownCardId, CancellationToken cancellationToken = default);
    Task<int> SumSaveCountByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<int> CountByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
}
