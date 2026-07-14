namespace Cardence.Domain.Entities;

/// <summary>
/// Bir kullanıcı kartınızı cüzdanına eklediğinde oluşan karşılıklı ekleme daveti.
/// Davet edilen kişi, davet edenin kartını cüzdanına ekleyebilir.
/// </summary>
public sealed class WalletCardInvite
{
    public Guid Id { get; set; }
    public Guid InviterUserId { get; set; }
    public Guid InviteeUserId { get; set; }
    public Guid ProposedCardEntityId { get; set; }
    public string ProposedCardId { get; set; } = string.Empty;
    public string SavedCardId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAtUtc { get; set; }
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime? RespondedAtUtc { get; set; }

    public User InviterUser { get; set; } = null!;
    public User InviteeUser { get; set; } = null!;
    public Card ProposedCard { get; set; } = null!;
}
