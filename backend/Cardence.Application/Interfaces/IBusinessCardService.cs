using Cardence.Application.DTOs.Cards;

namespace Cardence.Application.Interfaces;

public interface IBusinessCardService
{
    Task<IReadOnlyList<BusinessCardDto>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<BusinessCardDto> GetByCardIdAsync(string cardId, CancellationToken cancellationToken = default);
    Task<BusinessCardDto> CreateAsync(BusinessCardDto request, CancellationToken cancellationToken = default);
    Task<BusinessCardDto> UpsertAsync(string cardId, BusinessCardDto request, CancellationToken cancellationToken = default);
    Task DeleteAsync(string cardId, CancellationToken cancellationToken = default);
    Task<IReadOnlyDictionary<string, object?>> GetSharePayloadAsync(string cardId, CancellationToken cancellationToken = default);
    Task<IReadOnlyDictionary<string, object?>> GetPublicSharePayloadAsync(string cardId, CancellationToken cancellationToken = default);
    Task RecordPublicContactClickAsync(
        string cardId,
        string contactType,
        CancellationToken cancellationToken = default);
    Task<bool> PublicCardExistsAsync(string cardId, CancellationToken cancellationToken = default);
    Task<ProfileStatsDto> GetProfileStatsAsync(CancellationToken cancellationToken = default);
}
