namespace Cardence.Domain.Entities;

public sealed class SavedCardEventGroup
{
    public Guid SavedCardId { get; set; }
    public Guid EventGroupId { get; set; }

    public SavedCard SavedCard { get; set; } = null!;
    public EventGroup EventGroup { get; set; } = null!;
}
