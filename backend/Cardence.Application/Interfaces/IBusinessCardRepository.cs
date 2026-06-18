using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IBusinessCardRepository
{
    Task<IReadOnlyList<BusinessCard>> GetByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<BusinessCard?> GetByUserAndCardIdAsync(Guid userId, string cardId, CancellationToken cancellationToken = default);
    Task<BusinessCard?> GetByCardIdAsync(string cardId, CancellationToken cancellationToken = default);
    Task<bool> CardIdExistsAsync(string cardId, Guid? excludeId = null, CancellationToken cancellationToken = default);
    Task AddAsync(BusinessCard card, CancellationToken cancellationToken = default);
    Task UpdateAsync(BusinessCard card, CancellationToken cancellationToken = default);
    Task DeleteAsync(BusinessCard card, CancellationToken cancellationToken = default);
    Task IncrementSaveCountAsync(Guid businessCardId, CancellationToken cancellationToken = default);
    Task<int> SumSaveCountByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
}
