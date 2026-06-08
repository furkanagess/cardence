namespace Cardence.Application.DTOs.Auth;

public sealed class UserProfileEntity
{
    public required string UserId { get; init; }
    public string? DisplayName { get; init; }
    public string? Email { get; init; }
    public string? Phone { get; init; }
    public bool OnboardingCompleted { get; init; }
    public DateTime CreatedAt { get; init; }
}
