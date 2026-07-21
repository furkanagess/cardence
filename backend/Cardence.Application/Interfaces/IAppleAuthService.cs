using Cardence.Application.DTOs.Auth;

namespace Cardence.Application.Interfaces;

public interface IAppleAuthService
{
    Task<ExternalAuthValidationResult> ValidateIdentityTokenAsync(
        string identityToken,
        string? givenName = null,
        string? familyName = null,
        CancellationToken cancellationToken = default);
}
