namespace Cardence.Application.Interfaces;

public interface IWalletOwnerPremiumSyncService
{
    Task SyncForUserAsync(
        Guid userId,
        string tier,
        CancellationToken cancellationToken = default);
}
