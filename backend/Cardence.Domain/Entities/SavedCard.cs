namespace Cardence.Domain.Entities;

/// <summary>
/// Cüzdan görünümü: users.saved_card_ids + cards satırından üretilen projeksiyon (persist edilmez).
/// </summary>
public sealed class SavedCard
{
    public Guid UserId { get; set; }
    public string CardId { get; set; } = string.Empty;
    public string CreationMethod { get; set; } = string.Empty;

    public string? DisplayName { get; set; }
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public string? Company { get; set; }
    public string? Title { get; set; }
    public string? Website { get; set; }
    public string? Linkedin { get; set; }
    public string? Skills { get; set; }
    public string? School { get; set; }
    public string? About { get; set; }
    public string? Address { get; set; }
    public string? City { get; set; }
    public string? Country { get; set; }
    public string? Department { get; set; }
    public string? AttendedEvents { get; set; }
    public string? Twitter { get; set; }
    public string? Instagram { get; set; }
    public string? Birthday { get; set; }
    public string? Note { get; set; }
    public string? PhotoUrl { get; set; }
    public string? AccentColor { get; set; }
    public string? BackgroundColor { get; set; }
    public long SavedAt { get; set; }
    public int SortOrder { get; set; }
    public bool IsOwnerPremium { get; set; }
    public bool IsWalletContact { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public List<string> LinkedEventGroupIds { get; set; } = [];
}
