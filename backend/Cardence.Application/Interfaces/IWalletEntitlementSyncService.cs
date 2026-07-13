namespace Cardence.Application.Interfaces;

public interface IWalletEntitlementSyncService
{
    /// <summary>
    /// RevenueCat abonelik durumunu okuyup wallet tier ve isOwnerPremium bayraklarını günceller.
    /// API yoksa veya hata olursa sessizce atlanır.
    /// </summary>
    Task SyncUserFromRevenueCatAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// RevenueCat sonucu bilinmiyorsa satın alma sonrası premium'a yükseltir.
    /// </summary>
    Task SyncUserAfterClientPurchaseAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
