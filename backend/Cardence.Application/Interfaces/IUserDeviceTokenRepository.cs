using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IUserDeviceTokenRepository
{
    Task<UserDeviceToken?> GetByUserAndTokenAsync(
        Guid userId,
        string token,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<string>> GetTokensByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task UpsertAsync(
        UserDeviceToken token,
        CancellationToken cancellationToken = default);

    Task DeleteByUserAndTokenAsync(
        Guid userId,
        string token,
        CancellationToken cancellationToken = default);

    Task DeleteTokensAsync(
        IReadOnlyList<string> tokens,
        CancellationToken cancellationToken = default);
}
