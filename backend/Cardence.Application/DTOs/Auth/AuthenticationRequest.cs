namespace Cardence.Application.DTOs.Auth;

public sealed class AuthenticationRequest
{
    public string? UserId { get; init; }
    public string? Email { get; init; }
    public string? Password { get; init; }
    public string? UdId { get; init; }
    public string? ApiKey { get; init; }
    public bool AlreadyTryOtherMethod { get; init; }
}
