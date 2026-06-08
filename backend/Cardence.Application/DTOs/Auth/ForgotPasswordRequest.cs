namespace Cardence.Application.DTOs.Auth;

public sealed class ForgotPasswordRequest
{
    public string? Email { get; init; }
    public string? Phone { get; init; }
}
