namespace Cardence.Application.DTOs.Cards;

public sealed class BusinessCardDto
{
    public string? CardName { get; init; }
    public string? DisplayName { get; init; }
    public string? Email { get; init; }
    public string? Phone { get; init; }
    public string? Company { get; init; }
    public string? Title { get; init; }
    public string? Website { get; init; }
    public string? Linkedin { get; init; }
    public string? Skills { get; init; }
    public string? School { get; init; }
    public string? About { get; init; }
    public string? Address { get; init; }
    public string? City { get; init; }
    public string? Country { get; init; }
    public string? Department { get; init; }
    public string? AttendedEvents { get; init; }
    public string? Twitter { get; init; }
    public string? Instagram { get; init; }
    public string? Birthday { get; init; }
    public string? PhotoUrl { get; init; }
    public string? AccentColor { get; init; }
    public string? BackgroundColor { get; init; }
    public string? LastUsedPaletteBackgroundColor { get; init; }
    public IReadOnlyList<string> LinkedEventGroupIds { get; init; } = [];
    public string? CardId { get; init; }
    public bool IsOwnerPremium { get; init; }
    public string? CreationMethod { get; init; }
}
