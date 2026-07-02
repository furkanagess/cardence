namespace Cardence.Application.Common;

public static class EventGroupInvitationPolicy
{
    public const int ExpirationDays = 7;

    public static DateTime ComputeExpiresAtUtc(DateTime createdAtUtc) =>
        createdAtUtc.AddDays(ExpirationDays);

    public static bool IsExpired(DateTime expiresAtUtc, DateTime? utcNow = null) =>
        expiresAtUtc <= (utcNow ?? DateTime.UtcNow);
}
