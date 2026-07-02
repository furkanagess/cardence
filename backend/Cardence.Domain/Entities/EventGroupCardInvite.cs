namespace Cardence.Domain.Entities;

public sealed class EventGroupCardInvite
{
    public Guid Id { get; set; }
    public Guid EventGroupId { get; set; }
    public Guid InviterUserId { get; set; }
    public Guid InviteeUserId { get; set; }
    public Guid CardEntityId { get; set; }
    public string CardId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime? RespondedAtUtc { get; set; }

    public EventGroup EventGroup { get; set; } = null!;
    public User InviterUser { get; set; } = null!;
    public User InviteeUser { get; set; } = null!;
    public Card Card { get; set; } = null!;
}
