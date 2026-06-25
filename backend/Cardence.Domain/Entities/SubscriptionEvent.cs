namespace Cardence.Domain.Entities;

public sealed class SubscriptionEvent
{
    public Guid Id { get; set; }
    public string Provider { get; set; } = "revenuecat";
    public required string ProviderEventId { get; set; }
    public Guid UserId { get; set; }
    public required string EventType { get; set; }
    public required string PayloadJson { get; set; }
    public DateTime ProcessedAt { get; set; }

    public User? User { get; set; }
}
