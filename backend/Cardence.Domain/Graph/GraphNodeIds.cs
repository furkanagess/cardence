using System.Text.RegularExpressions;

namespace Cardence.Domain.Graph;

/// <summary>
/// Graph node kimlikleri ve company slug normalizasyonu.
/// </summary>
public static partial class GraphNodeIds
{
    public static string User(Guid userId) => $"user:{userId:D}";

    public static string Card(string cardId) => $"card:{cardId}";

    public static string Company(string companyName)
    {
        var slug = NormalizeCompanySlug(companyName);
        return $"company:{slug}";
    }

    public static string Event(Guid eventGroupId) => $"event:{eventGroupId:D}";

    public static string Organization(Guid organizationId) => $"org:{organizationId:D}";

    public static string OrganizationEvent(Guid organizationEventId) =>
        $"org_event:{organizationEventId:D}";

    public static string Skill(string token) => $"skill:{token.Trim().ToLowerInvariant()}";

    public static string Location(string slug) => $"loc:{slug.Trim().ToLowerInvariant()}";

    public static string NormalizeCompanySlug(string? companyName)
    {
        if (string.IsNullOrWhiteSpace(companyName))
        {
            return "unknown";
        }

        var normalized = companyName.Trim().ToLowerInvariant();
        normalized = NonAlphanumericRegex().Replace(normalized, "-");
        normalized = CollapseDashRegex().Replace(normalized, "-").Trim('-');
        return string.IsNullOrEmpty(normalized) ? "unknown" : normalized;
    }

    public static string Edge(
        GraphEdgeType type,
        string sourceNodeId,
        string targetNodeId) =>
        $"edge:{type.ToString().ToLowerInvariant()}:{sourceNodeId}:{targetNodeId}";

    [GeneratedRegex(@"[^a-z0-9]+", RegexOptions.CultureInvariant)]
    private static partial Regex NonAlphanumericRegex();

    [GeneratedRegex(@"-{2,}", RegexOptions.CultureInvariant)]
    private static partial Regex CollapseDashRegex();
}
