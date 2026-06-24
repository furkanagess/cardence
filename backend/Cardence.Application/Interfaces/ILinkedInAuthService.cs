using Cardence.Application.DTOs.Auth;

namespace Cardence.Application.Interfaces;

public interface ILinkedInAuthService
{
    Task<LinkedInUserInfo?> ExchangeAuthorizationCodeAsync(
        string authorizationCode,
        string redirectUri,
        CancellationToken cancellationToken = default);
}
