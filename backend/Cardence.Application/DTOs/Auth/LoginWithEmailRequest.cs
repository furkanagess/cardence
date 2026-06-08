namespace Cardence.Application.DTOs.Auth;

public sealed class LoginWithEmailRequest
{
    public string Email { get; init; } = string.Empty;
    public string? Password { get; init; }
    public string? OtpCode { get; init; }
    public string? UdId { get; init; }
}
