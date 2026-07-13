using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;

namespace Cardence.Application.Services;

public sealed class WalletEntitlementSyncService : IWalletEntitlementSyncService
{
    private readonly IRevenueCatEntitlementClient _revenueCatClient;
    private readonly IWalletEntitlementRepository _walletRepository;
    private readonly IWalletOwnerPremiumSyncService _ownerPremiumSync;

    public WalletEntitlementSyncService(
        IRevenueCatEntitlementClient revenueCatClient,
        IWalletEntitlementRepository walletRepository,
        IWalletOwnerPremiumSyncService ownerPremiumSync)
    {
        _revenueCatClient = revenueCatClient;
        _walletRepository = walletRepository;
        _ownerPremiumSync = ownerPremiumSync;
    }

    public async Task SyncUserFromRevenueCatAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var rcActive = await _revenueCatClient.HasActivePremiumEntitlementAsync(
            userId,
            cancellationToken);
        if (!rcActive.HasValue)
        {
            return;
        }

        await ApplyTierAsync(userId, rcActive.Value, cancellationToken);
    }

    public async Task SyncUserAfterClientPurchaseAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var rcActive = await _revenueCatClient.HasActivePremiumEntitlementAsync(
            userId,
            cancellationToken);
        if (rcActive == true)
        {
            await ApplyTierAsync(userId, isPremium: true, cancellationToken);
            return;
        }

        if (rcActive == false)
        {
            await ApplyTierAsync(userId, isPremium: false, cancellationToken);
            return;
        }

        var entitlement = await _walletRepository.GetOrCreateAsync(userId, cancellationToken);
        if (!WalletConstants.IsPremiumOrHigher(entitlement.Tier))
        {
            entitlement = await _walletRepository.UpgradeToPremiumAsync(userId, cancellationToken);
        }

        await _ownerPremiumSync.SyncForUserAsync(
            userId,
            entitlement.Tier,
            cancellationToken);
    }

    private async Task ApplyTierAsync(
        Guid userId,
        bool isPremium,
        CancellationToken cancellationToken)
    {
        var tier = isPremium ? WalletConstants.PremiumTier : WalletConstants.FreeTier;
        var maxCards = isPremium
            ? WalletConstants.PremiumMaxCards
            : WalletConstants.FreeMaxCards;

        await _walletRepository.SetTierAsync(userId, tier, maxCards, cancellationToken);
        await _ownerPremiumSync.SyncForUserAsync(userId, tier, cancellationToken);
    }
}
