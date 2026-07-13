namespace Cardence.Domain.Entities;

/// <summary>
/// Kart etkilesim olaylari; public goruntuleme/iletisim ve kart olusturma kaynagi.
/// </summary>
public sealed class CardInteraction
{
    public Guid Id { get; set; }
    public Guid? ActorUserId { get; set; }
    public Guid TargetCardEntityId { get; set; }
    public required string TargetCardPublicId { get; set; }
    public required string EventType { get; set; }
    public string Source { get; set; } = "public";
    public Guid? OrganizationEventId { get; set; }
    public DateTime OccurredAt { get; set; }

    public User? ActorUser { get; set; }
    public Card TargetCard { get; set; } = null!;
}
