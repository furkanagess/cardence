namespace Cardence.Application.DTOs.Plans;

public sealed class PlanLimitsDto
{
    public int? MaxBusinessCards { get; init; }
    public int? MaxSavedCards { get; init; }
    public int? MaxEventGroups { get; init; }
    public int MaxTeamSeats { get; init; } = 1;
}
