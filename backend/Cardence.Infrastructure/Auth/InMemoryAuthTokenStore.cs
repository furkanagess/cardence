using System.Collections.Concurrent;
using Cardence.Application.Interfaces;

namespace Cardence.Infrastructure.Auth;

public sealed class InMemoryAuthTokenStore : IAuthTokenStore
{
    private readonly ConcurrentDictionary<string, OtpEntry> _otpCodes = new();
    private readonly ConcurrentDictionary<string, RefreshEntry> _refreshTokens = new();

    public Task SaveOtpAsync(
        string key,
        string code,
        TimeSpan lifetime,
        CancellationToken cancellationToken = default)
    {
        _otpCodes[key] = new OtpEntry(code, DateTime.UtcNow.Add(lifetime));
        return Task.CompletedTask;
    }

    public Task<bool> ValidateOtpAsync(
        string key,
        string code,
        CancellationToken cancellationToken = default)
    {
        if (!_otpCodes.TryGetValue(key, out var entry))
        {
            return Task.FromResult(false);
        }

        if (entry.ExpiresAtUtc < DateTime.UtcNow)
        {
            _otpCodes.TryRemove(key, out _);
            return Task.FromResult(false);
        }

        var isValid = string.Equals(entry.Code, code.Trim(), StringComparison.Ordinal);
        if (isValid)
        {
            _otpCodes.TryRemove(key, out _);
        }

        return Task.FromResult(isValid);
    }

    public Task SaveRefreshTokenAsync(
        Guid userId,
        string token,
        DateTime expiresAtUtc,
        CancellationToken cancellationToken = default)
    {
        _refreshTokens[token] = new RefreshEntry(userId, expiresAtUtc);
        return Task.CompletedTask;
    }

    public Task<Guid?> GetUserIdByRefreshTokenAsync(
        string token,
        CancellationToken cancellationToken = default)
    {
        if (!_refreshTokens.TryGetValue(token, out var entry))
        {
            return Task.FromResult<Guid?>(null);
        }

        if (entry.ExpiresAtUtc < DateTime.UtcNow)
        {
            _refreshTokens.TryRemove(token, out _);
            return Task.FromResult<Guid?>(null);
        }

        return Task.FromResult<Guid?>(entry.UserId);
    }

    private sealed record OtpEntry(string Code, DateTime ExpiresAtUtc);
    private sealed record RefreshEntry(Guid UserId, DateTime ExpiresAtUtc);
}
