namespace Cardence.Domain.Entities;

/// <summary>
/// Kullanıcının oluşturduğu kendi kartvizit kartı.
/// </summary>
public sealed class Card
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string CardId { get; set; } = string.Empty;

    public string? CardName { get; set; }
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
    public string? PhotoUrl { get; set; }
    public string? AccentColor { get; set; }
    public string? BackgroundColor { get; set; }
    public string? CardEffect { get; set; }
    public int SaveCount { get; set; }
    public bool IsOwnerPremium { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public User User { get; set; } = null!;
}
