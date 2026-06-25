namespace Cardence.Application.DTOs.Plans;

public sealed class PlanFeaturesDto
{
    public bool AdsDisabled { get; init; }
    public bool AdvancedDesigns { get; init; }
    public bool ProfileStats { get; init; }
    public bool CsvExport { get; init; }
    public bool NetworkGraph { get; init; }
    public bool WalletPass { get; init; }
    public bool CrmIntegration { get; init; }
}
