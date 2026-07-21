using Cardence.Application.DTOs.Auth;

namespace Cardence.Application.Interfaces;

public interface IGoogleAuthService
{
    Task<ExternalAuthValidationResult> ValidateIdTokenAsync(
        string idToken,
        CancellationToken cancellationToken = default);
}
