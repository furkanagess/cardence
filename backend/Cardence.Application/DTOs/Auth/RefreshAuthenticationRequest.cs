namespace Cardence.Application.DTOs.Auth;

public sealed class RefreshAuthenticationRequest
{
    public string RefreshToken { get; init; } = string.Empty;
}
