namespace Cardence.Domain.Entities;

/// <summary>
/// Kullanıcı cüzdanındaki bir kartın etkinlik grubuna bağlantısı (user + card_id).
/// </summary>
public sealed class EventGroupWalletCard
{
    public Guid UserId { get; set; }
    public string CardId { get; set; } = string.Empty;
    public Guid EventGroupId { get; set; }

    public User User { get; set; } = null!;
    public EventGroup EventGroup { get; set; } = null!;
}
