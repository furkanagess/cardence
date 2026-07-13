namespace Cardence.Application.Interfaces;

public interface IRevenueCatEntitlementClient
{
    /// <summary>
    /// RevenueCat'te aktif premium entitlement var mı?
    /// null: API yapılandırılmamış veya geçici hata — mevcut DB tier'ı koru.
    /// </summary>
    Task<bool?> HasActivePremiumEntitlementAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
