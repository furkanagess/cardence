namespace Cardence.Application.DTOs.Auth;

public sealed class LoginWithGoogleRequest
{
    public string IdToken { get; init; } = string.Empty;
    public string? UdId { get; init; }
}
