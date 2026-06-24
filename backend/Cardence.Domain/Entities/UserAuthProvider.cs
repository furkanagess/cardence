namespace Cardence.Domain.Entities;

public sealed class UserAuthProvider
{
    public string ProviderId { get; set; } = string.Empty;
    public string ProviderUserId { get; set; } = string.Empty;
    public Guid UserId { get; set; }

    public User User { get; set; } = null!;
}
