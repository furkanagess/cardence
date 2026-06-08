namespace Cardence.Application.Interfaces;

public interface IAuthTokenStore
{
    Task SaveOtpAsync(string key, string code, TimeSpan lifetime, CancellationToken cancellationToken = default);
    Task<bool> ValidateOtpAsync(string key, string code, CancellationToken cancellationToken = default);
    Task SaveRefreshTokenAsync(Guid userId, string token, DateTime expiresAtUtc, CancellationToken cancellationToken = default);
    Task<Guid?> GetUserIdByRefreshTokenAsync(string token, CancellationToken cancellationToken = default);
}
