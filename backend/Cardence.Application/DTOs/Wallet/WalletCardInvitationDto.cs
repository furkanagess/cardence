namespace Cardence.Application.DTOs.Wallet;

public sealed class WalletCardInvitationDto
{
    public string Id { get; set; } = string.Empty;
    public string InviterUserId { get; set; } = string.Empty;
    public string InviterName { get; set; } = string.Empty;
    public string? InviterPhotoUrl { get; set; }
    public string ProposedCardId { get; set; } = string.Empty;
    public string? ProposedCardDisplayName { get; set; }
    public string? ProposedCardTitle { get; set; }
    public string? ProposedCardCompany { get; set; }
    public string? ProposedCardPhotoUrl { get; set; }
    public string SavedCardId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
}

public sealed class RespondWalletCardInvitationRequest
{
    public string Id { get; set; } = string.Empty;
}
