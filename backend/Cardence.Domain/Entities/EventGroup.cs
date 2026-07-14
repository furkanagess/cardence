namespace Cardence.Domain.Entities;

public sealed class EventGroup
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Location { get; set; }
    public string? Description { get; set; }
    public DateTime StartAtUtc { get; set; }
    public DateTime? EndAtUtc { get; set; }
    public string? Timezone { get; set; }
    public DateTime? EventDate { get; set; }
    public string? PhotoUrl { get; set; }
    public DateTime CreatedAt { get; set; }

    public User User { get; set; } = null!;
    public ICollection<EventGroupWalletCard> WalletCardLinks { get; set; } = [];
    public ICollection<EventGroupCardInvite> CardInvites { get; set; } = [];
}
