using Cardence.Application.DTOs.Cards;
using Cardence.Application.DTOs.Wallet;

namespace Cardence.Application.DTOs.Auth;

public sealed class UserProfileEntity
{
    public required string UserId { get; init; }
    public string? DisplayName { get; init; }
    public string? Email { get; init; }
    public string? Phone { get; init; }
    public string? PhotoUrl { get; init; }
    public bool OnboardingCompleted { get; init; }
    public bool Premium { get; init; }
    public DateTime CreatedAt { get; init; }
    public IReadOnlyList<SavedCardDto> SavedCards { get; init; } = [];
    public IReadOnlyList<BusinessCardDto> BusinessCards { get; init; } = [];
}
