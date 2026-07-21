namespace Cardence.Application.DTOs.Auth;

public sealed class LoginWithAppleRequest
{
    public string IdentityToken { get; init; } = string.Empty;
    public string? AuthorizationCode { get; init; }
    public string? GivenName { get; init; }
    public string? FamilyName { get; init; }
    public string? UdId { get; init; }
}
