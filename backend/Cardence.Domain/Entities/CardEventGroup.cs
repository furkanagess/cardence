namespace Cardence.Domain.Entities;

public sealed class CardEventGroup
{
    public Guid CardId { get; set; }
    public Guid EventGroupId { get; set; }

    public Card Card { get; set; } = null!;
    public EventGroup EventGroup { get; set; } = null!;
}
