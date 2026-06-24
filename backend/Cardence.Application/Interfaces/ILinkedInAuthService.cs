using Cardence.Application.DTOs.Auth;

namespace Cardence.Application.Interfaces;

public interface ILinkedInAuthService
{
    Task<LinkedInExchangeResult> ExchangeAuthorizationCodeAsync(
        string authorizationCode,
        string redirectUri,
        CancellationToken cancellationToken = default);
}
