namespace Cardence.Application.DTOs.EventGroups;

/// Etkinlik sahibi için gruba gönderilmiş kart daveti.
public sealed class EventGroupOutboundInvitationDto
{
    public string Id { get; set; } = string.Empty;
    public string EventGroupId { get; set; } = string.Empty;
    public string CardId { get; set; } = string.Empty;
    public string? CardDisplayName { get; set; }
    public string? CardTitle { get; set; }
    public string? CardCompany { get; set; }
    public string? CardPhotoUrl { get; set; }
    public string? InviteeName { get; set; }
    public string? InviteePhotoUrl { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
}
