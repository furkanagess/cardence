using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IWalletEntitlementRepository
{
    Task<WalletEntitlement> GetOrCreateAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<WalletEntitlement> UpgradeToPremiumAsync(
        Guid userId,
        CancellationToken cancellationToken = default);
}
