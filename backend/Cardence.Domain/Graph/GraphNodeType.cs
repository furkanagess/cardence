namespace Cardence.Domain.Graph;

/// <summary>
/// Network graph dugum tipleri. Bkz. docs/PRICING_NETWORK_GRAPH_THEORY.md §2.
/// </summary>
public enum GraphNodeType
{
    User,
    Card,
    Company,
    Event,
    Organization,
    OrganizationEvent,
    Skill,
    Location,
}
