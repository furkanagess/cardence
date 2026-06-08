namespace Cardence.Domain.Entities;

public sealed class AuthRefreshToken
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public required string Token { get; set; }
    public DateTime ExpiresAtUtc { get; set; }
    public DateTime CreatedAtUtc { get; set; }

    public User? User { get; set; }
}
