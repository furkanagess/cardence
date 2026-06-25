namespace Cardence.Application.DTOs.Plans;

public sealed class PlanEntitlementsDto
{
    public string Tier { get; init; } = "free";
    public PlanFeaturesDto Features { get; init; } = new();
    public PlanLimitsDto Limits { get; init; } = new();
}
