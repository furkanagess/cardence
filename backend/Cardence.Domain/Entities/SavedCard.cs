namespace Cardence.Domain.Entities;

public sealed class SavedCard
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string CardId { get; set; } = string.Empty;
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
    public string? Note { get; set; }
    public string? AccentColor { get; set; }
    public string? BackgroundColor { get; set; }
    public long SavedAt { get; set; }
    public int SortOrder { get; set; }
    /// <summary>
    /// API yanıtı için join tablosundan doldurulur; jsonb kolonuna yazılmaz.
    /// </summary>
    public List<string> LinkedEventGroupIds { get; set; } = [];

    public User User { get; set; } = null!;
    public ICollection<SavedCardEventGroup> EventGroupLinks { get; set; } = [];
}
