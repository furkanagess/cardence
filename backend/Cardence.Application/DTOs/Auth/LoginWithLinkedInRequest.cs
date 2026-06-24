namespace Cardence.Application.DTOs.Auth;

public sealed class LoginWithLinkedInRequest
{
    public string AuthorizationCode { get; init; } = string.Empty;
    public string RedirectUri { get; init; } = string.Empty;
    public string? UdId { get; init; }
}
