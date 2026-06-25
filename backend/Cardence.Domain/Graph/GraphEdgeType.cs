namespace Cardence.Domain.Graph;

/// <summary>
/// Network graph kenar tipleri. Bkz. docs/PRICING_NETWORK_GRAPH_THEORY.md §3.
/// </summary>
public enum GraphEdgeType
{
    Owns,
    Saved,
    Scanned,
    Viewed,
    ContactClicked,
    WorksAt,
    MetAtEvent,
    CoSaved,
    SameCompany,
    AssignedLead,
    OrgEventLink,
}
