using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Cardence.Application.DTOs.Auth;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Cardence.Infrastructure.Auth;

public sealed class AppleAuthService : IAppleAuthService
{
    private const string AppleIssuer = "https://appleid.apple.com";
    private const string AppleKeysEndpoint = "https://appleid.apple.com/auth/keys";

    private readonly HttpClient _httpClient;
    private readonly AppleAuthOptions _options;
    private readonly ILogger<AppleAuthService> _logger;
    private readonly SemaphoreSlim _keysLock = new(1, 1);
    private IReadOnlyList<SecurityKey>? _cachedKeys;
    private DateTimeOffset _keysFetchedAt = DateTimeOffset.MinValue;

    public AppleAuthService(
        HttpClient httpClient,
        IOptions<AppleAuthOptions> options,
        ILogger<AppleAuthService> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<ExternalAuthValidationResult> ValidateIdentityTokenAsync(
        string identityToken,
        string? givenName = null,
        string? familyName = null,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.ClientId))
        {
            _logger.LogWarning("Apple OAuth is not configured (missing ClientId).");
            return ExternalAuthValidationResult.Failed(
                "Apple girişi sunucuda yapılandırılmamış. Client ID kontrol edin.");
        }

        if (string.IsNullOrWhiteSpace(identityToken))
        {
            return ExternalAuthValidationResult.Failed("Apple kimlik jetonu gereklidir.");
        }

        try
        {
            var signingKeys = await GetAppleSigningKeysAsync(cancellationToken);
            var validationParameters = new TokenValidationParameters
            {
                ValidIssuer = AppleIssuer,
                ValidAudience = _options.ClientId,
                IssuerSigningKeys = signingKeys,
                ValidateIssuer = true,
                ValidateAudience = true,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                ClockSkew = TimeSpan.FromMinutes(2),
            };

            var handler = new JwtSecurityTokenHandler();
            var principal = handler.ValidateToken(
                identityToken.Trim(),
                validationParameters,
                out _);

            var sub = principal.FindFirstValue("sub")
                ?? principal.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrWhiteSpace(sub))
            {
                return ExternalAuthValidationResult.Failed("Apple oturumu doğrulanamadı.");
            }

            var email = principal.FindFirstValue("email")
                ?? principal.FindFirstValue(ClaimTypes.Email);
            var displayName = BuildDisplayName(givenName, familyName, email);

            return ExternalAuthValidationResult.Ok(
                new ExternalAuthUserInfo
                {
                    Sub = sub,
                    Email = string.IsNullOrWhiteSpace(email)
                        ? null
                        : email.Trim().ToLowerInvariant(),
                    DisplayName = displayName,
                    PictureUrl = null,
                });
        }
        catch (SecurityTokenException ex)
        {
            _logger.LogWarning(ex, "Apple identityToken validation failed.");
            return ExternalAuthValidationResult.Failed("Apple oturumu doğrulanamadı.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error validating Apple identityToken.");
            return ExternalAuthValidationResult.Failed("Apple oturumu doğrulanamadı.");
        }
    }

    private async Task<IReadOnlyList<SecurityKey>> GetAppleSigningKeysAsync(
        CancellationToken cancellationToken)
    {
        if (_cachedKeys is { Count: > 0 }
            && DateTimeOffset.UtcNow - _keysFetchedAt < TimeSpan.FromHours(12))
        {
            return _cachedKeys;
        }

        await _keysLock.WaitAsync(cancellationToken);
        try
        {
            if (_cachedKeys is { Count: > 0 }
                && DateTimeOffset.UtcNow - _keysFetchedAt < TimeSpan.FromHours(12))
            {
                return _cachedKeys;
            }

            using var response = await _httpClient.GetAsync(AppleKeysEndpoint, cancellationToken);
            response.EnsureSuccessStatusCode();
            var json = await response.Content.ReadAsStringAsync(cancellationToken);
            var keySet = JsonSerializer.Deserialize<AppleJwksResponse>(json)
                ?? throw new InvalidOperationException("Apple JWKS yanıtı boş.");

            var keys = new List<SecurityKey>();
            foreach (var key in keySet.Keys ?? [])
            {
                if (!string.Equals(key.Kty, "RSA", StringComparison.OrdinalIgnoreCase)
                    || string.IsNullOrWhiteSpace(key.N)
                    || string.IsNullOrWhiteSpace(key.E))
                {
                    continue;
                }

                var rsa = RSA.Create();
                rsa.ImportParameters(new RSAParameters
                {
                    Modulus = Base64UrlEncoder.DecodeBytes(key.N),
                    Exponent = Base64UrlEncoder.DecodeBytes(key.E),
                });
                keys.Add(new RsaSecurityKey(rsa) { KeyId = key.Kid });
            }

            if (keys.Count == 0)
            {
                throw new InvalidOperationException("Apple JWKS anahtarı bulunamadı.");
            }

            _cachedKeys = keys;
            _keysFetchedAt = DateTimeOffset.UtcNow;
            return _cachedKeys;
        }
        finally
        {
            _keysLock.Release();
        }
    }

    private static string? BuildDisplayName(
        string? givenName,
        string? familyName,
        string? email)
    {
        var parts = new StringBuilder();
        if (!string.IsNullOrWhiteSpace(givenName))
        {
            parts.Append(givenName.Trim());
        }

        if (!string.IsNullOrWhiteSpace(familyName))
        {
            if (parts.Length > 0)
            {
                parts.Append(' ');
            }

            parts.Append(familyName.Trim());
        }

        if (parts.Length > 0)
        {
            return parts.ToString();
        }

        return string.IsNullOrWhiteSpace(email) ? null : email.Trim();
    }

    private sealed class AppleJwksResponse
    {
        [JsonPropertyName("keys")]
        public List<AppleJwk>? Keys { get; init; }
    }

    private sealed class AppleJwk
    {
        [JsonPropertyName("kty")]
        public string? Kty { get; init; }

        [JsonPropertyName("kid")]
        public string? Kid { get; init; }

        [JsonPropertyName("n")]
        public string? N { get; init; }

        [JsonPropertyName("e")]
        public string? E { get; init; }
    }
}
