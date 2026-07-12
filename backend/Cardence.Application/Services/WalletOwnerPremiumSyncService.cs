using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;

namespace Cardence.Application.Services;

public sealed class WalletOwnerPremiumSyncService : IWalletOwnerPremiumSyncService
{
    private readonly IBusinessCardRepository _businessCardRepository;
    private readonly ISavedCardRepository _savedCardRepository;

    public WalletOwnerPremiumSyncService(
        IBusinessCardRepository businessCardRepository,
        ISavedCardRepository savedCardRepository)
    {
        _businessCardRepository = businessCardRepository;
        _savedCardRepository = savedCardRepository;
    }

    public async Task SyncForUserAsync(
        Guid userId,
        string tier,
        CancellationToken cancellationToken = default)
    {
        var normalizedTier = WalletConstants.NormalizeTier(tier);
        var isOwnerPremium = WalletConstants.IsPremiumOrHigher(normalizedTier);

        await _businessCardRepository.SetOwnerPremiumByUserIdAsync(
            userId,
            isOwnerPremium,
            cancellationToken);

        var cardIds = await _businessCardRepository.GetCardIdsByUserIdAsync(
            userId,
            cancellationToken);
        await _savedCardRepository.SetOwnerPremiumByCardIdsAsync(
            cardIds,
            isOwnerPremium,
            cancellationToken);
        await _savedCardRepository.ReconcileOwnerPremiumWithCardsAsync(
            cancellationToken);
    }
}
