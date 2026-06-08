namespace Cardence.Application.DTOs.Auth;

public sealed class RegisterRequest
{
    public string? DisplayName { get; init; }
    public string? Email { get; init; }
    public string? Phone { get; init; }
    public string? Password { get; init; }
}
