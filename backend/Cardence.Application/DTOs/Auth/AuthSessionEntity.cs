namespace Cardence.Application.DTOs.Auth;

public sealed class AuthSessionEntity
{
    public required string AccessToken { get; init; }
    public string? RefreshToken { get; init; }
    public required string UserId { get; init; }
    public int ExpiresIn { get; init; }
    public string? Email { get; init; }
    public string? Phone { get; init; }
    public string? DisplayName { get; init; }
}
