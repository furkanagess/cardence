namespace Cardence.Domain.Entities;

public sealed class User
{
    public Guid Id { get; set; }
    public string? DisplayName { get; set; }
    public string? Email { get; set; }
    public string? Phone { get; set; }
    public string? PhotoUrl { get; set; }
    public string? PasswordHash { get; set; }
    public bool OnboardingCompleted { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    /// <summary>Cüzdandaki kartların public card_id listesi (tekilleştirilmiş, sıralı).</summary>
    public List<string> SavedCardIds { get; set; } = [];

    /// <summary>card_id → kullanıcı notu.</summary>
    public Dictionary<string, string> SavedCardNotes { get; set; } = new(StringComparer.Ordinal);

    public ICollection<Card> Cards { get; set; } = [];
    public ICollection<UserAuthProvider> AuthProviders { get; set; } = [];
    public ICollection<PasswordResetToken> PasswordResetTokens { get; set; } = [];
}
