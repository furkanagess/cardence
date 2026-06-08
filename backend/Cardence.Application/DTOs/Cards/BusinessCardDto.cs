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
    public string? AccentColor { get; init; }
    public string? BackgroundColor { get; init; }
    public string? LastUsedPaletteBackgroundColor { get; init; }
    public IReadOnlyList<string> LinkedEventGroupIds { get; init; } = [];
    public string? CardId { get; init; }
}
