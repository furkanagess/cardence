namespace Cardence.Domain.Entities;

public sealed class EventGroup
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    public User User { get; set; } = null!;
    public ICollection<SavedCardEventGroup> CardLinks { get; set; } = [];
}
