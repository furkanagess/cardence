namespace Cardence.Application.DTOs.Auth;

public sealed class ResetPasswordRequest
{
    public string? Email { get; init; }
    public string? Phone { get; init; }
    public string? OtpCode { get; init; }
    public string? ResetToken { get; init; }
    public string? NewPassword { get; init; }
}
