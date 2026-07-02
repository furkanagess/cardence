namespace Cardence.Application.DTOs.EventGroups;

public sealed class EventGroupInvitationDto
{
    public string Id { get; set; } = string.Empty;
    public string EventGroupId { get; set; } = string.Empty;
    public string EventName { get; set; } = string.Empty;
    public string? Location { get; set; }
    public DateTime StartAt { get; set; }
    public DateTime? EndAt { get; set; }
    public string? PhotoUrl { get; set; }
    public string InviterName { get; set; } = string.Empty;
    public string CardId { get; set; } = string.Empty;
    public string? CardDisplayName { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
}
