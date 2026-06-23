namespace Cardence.Domain.Entities;

/// <summary>
/// Cüzdana kaydedilen kart kopyası; kullanıcının kendi kartı (<see cref="Card"/>) değildir.
/// </summary>
public sealed class SavedCard
{
    public Guid Id { get; set; }
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
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    /// <summary>API yanıtı; join tablosundan doldurulur.</summary>
    public List<string> LinkedEventGroupIds { get; set; } = [];

    public User User { get; set; } = null!;
    public ICollection<SavedCardEventGroup> EventGroupLinks { get; set; } = [];
}
