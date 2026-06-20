using System.Text.Json;
using Cardence.Application.DTOs.Wallet;

namespace Cardence.Application.Interfaces;

public interface ISavedCardService
{
    Task<IReadOnlyList<SavedCardDto>> GetAllAsync(CancellationToken cancellationToken = default);

    Task<SavedCardDto> CreateFromJsonAsync(
        JsonElement body,
        CancellationToken cancellationToken = default);

    Task<SavedCardDto> UpdateAsync(
        SavedCardDto request,
        CancellationToken cancellationToken = default);

    Task DeleteAsync(string cardId, CancellationToken cancellationToken = default);

    Task<WalletQuotaDto> GetWalletQuotaAsync(CancellationToken cancellationToken = default);

    Task<WalletQuotaDto> UpgradeWalletPlanAsync(CancellationToken cancellationToken = default);
}
