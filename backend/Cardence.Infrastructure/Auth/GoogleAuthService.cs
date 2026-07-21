using Cardence.Application.DTOs.Auth;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Google.Apis.Auth;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Auth;

public sealed class GoogleAuthService : IGoogleAuthService
{
    private readonly GoogleAuthOptions _options;
    private readonly ILogger<GoogleAuthService> _logger;

    public GoogleAuthService(
        IOptions<GoogleAuthOptions> options,
        ILogger<GoogleAuthService> logger)
    {
        _options = options.Value;
        _logger = logger;
    }

    public async Task<ExternalAuthValidationResult> ValidateIdTokenAsync(
        string idToken,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.ClientId))
        {
            _logger.LogWarning("Google OAuth is not configured (missing ClientId).");
            return ExternalAuthValidationResult.Failed(
                "Google girişi sunucuda yapılandırılmamış. Client ID kontrol edin.");
        }

        if (string.IsNullOrWhiteSpace(idToken))
        {
            return ExternalAuthValidationResult.Failed("Google kimlik jetonu gereklidir.");
        }

        try
        {
            var settings = new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = [_options.ClientId],
            };

            var payload = await GoogleJsonWebSignature.ValidateAsync(
                idToken.Trim(),
                settings);

            if (string.IsNullOrWhiteSpace(payload.Subject))
            {
                return ExternalAuthValidationResult.Failed("Google oturumu doğrulanamadı.");
            }

            var displayName = FirstNonEmpty(payload.Name, payload.GivenName, payload.Email);

            return ExternalAuthValidationResult.Ok(
                new ExternalAuthUserInfo
                {
                    Sub = payload.Subject,
                    Email = string.IsNullOrWhiteSpace(payload.Email)
                        ? null
                        : payload.Email.Trim().ToLowerInvariant(),
                    DisplayName = displayName,
                    PictureUrl = string.IsNullOrWhiteSpace(payload.Picture)
                        ? null
                        : payload.Picture.Trim(),
                });
        }
        catch (InvalidJwtException ex)
        {
            _logger.LogWarning(ex, "Google idToken validation failed.");
            return ExternalAuthValidationResult.Failed("Google oturumu doğrulanamadı.");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Unexpected error validating Google idToken.");
            return ExternalAuthValidationResult.Failed("Google oturumu doğrulanamadı.");
        }
    }

    private static string? FirstNonEmpty(params string?[] values)
    {
        foreach (var value in values)
        {
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value.Trim();
            }
        }

        return null;
    }
}
