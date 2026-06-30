namespace Cardence.Application.Common;

public static class EventGroupStatuses
{
    public const string Upcoming = "upcoming";
    public const string Ongoing = "ongoing";
    public const string Ended = "ended";

    public static string Resolve(DateTime startAtUtc, DateTime? endAtUtc, DateTime? nowUtc = null)
    {
        var now = nowUtc ?? DateTime.UtcNow;
        var effectiveEndAt = endAtUtc ?? startAtUtc;

        if (now < startAtUtc)
        {
            return Upcoming;
        }

        return now <= effectiveEndAt ? Ongoing : Ended;
    }
}
