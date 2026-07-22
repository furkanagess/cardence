namespace Cardence.Application.Interfaces;

public interface IWalletEntitlementSyncService
{
    /// <summary>
    /// RevenueCat'te aktif premium varsa wallet tier'ı yükseltir.
    /// Downgrade yapmaz (Me poll / satın alma yarışı); iptal webhook ile gelir.
    /// </summary>
    Task SyncUserFromRevenueCatAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    /// <summary>
    /// İstemci satın alma / geri yükleme sonrası premium'a yükseltir.
    /// RevenueCat API gecikse bile bu çağrı premium verir; iptal webhook ile düşer.
    /// </summary>
    Task SyncUserAfterClientPurchaseAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
