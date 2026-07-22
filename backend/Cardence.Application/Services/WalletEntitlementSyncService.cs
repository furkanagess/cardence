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
        if (rcActive != true)
        {
            // false/null: Me/login poll'larında fresh purchase ile yarışıp
            // premium'u geri alma. İptal / süre bitimi webhook ile uygulanır.
            return;
        }

        await ApplyTierAsync(userId, isPremium: true, cancellationToken);
    }

    public async Task SyncUserAfterClientPurchaseAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        // İstemci satın alma sonrası: RC API gecikse / entitlement id eşleşmese
        // bile DB'ye premium yaz. Downgrade yalnızca EXPIRATION/REFUND webhook.
        await ApplyTierAsync(userId, isPremium: true, cancellationToken);
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
