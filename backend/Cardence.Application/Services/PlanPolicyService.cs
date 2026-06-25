using Cardence.Application.DTOs.Plans;
using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;

namespace Cardence.Application.Services;

public sealed class PlanPolicyService : IPlanPolicyService
{
    private readonly IWalletEntitlementRepository _walletRepository;
    private readonly ICurrentUserService _currentUser;

    public PlanPolicyService(
        IWalletEntitlementRepository walletRepository,
        ICurrentUserService currentUser)
    {
        _walletRepository = walletRepository;
        _currentUser = currentUser;
    }

    public async Task<PlanEntitlementsDto> GetEntitlementsAsync(
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var entitlement = await _walletRepository.GetOrCreateAsync(userId, cancellationToken);
        var tier = WalletConstants.NormalizeTier(entitlement.Tier);
        var premium = WalletConstants.IsPremiumOrHigher(tier);
        var business = WalletConstants.IsBusinessOrHigher(tier);

        return new PlanEntitlementsDto
        {
            Tier = tier,
            Features = new PlanFeaturesDto
            {
                AdsDisabled = premium,
                AdvancedDesigns = premium,
                ProfileStats = premium,
                CsvExport = premium,
                NetworkGraph = true,
                WalletPass = premium,
                CrmIntegration = business,
            },
            Limits = new PlanLimitsDto
            {
                MaxBusinessCards = WalletConstants.GetMaxBusinessCards(tier),
                MaxSavedCards = WalletConstants.HasUnlimitedWalletCards(tier)
                    ? null
                    : entitlement.MaxCards,
                MaxEventGroups = WalletConstants.HasUnlimitedEventGroups(tier)
                    ? null
                    : WalletConstants.FreeMaxEventGroups,
                MaxTeamSeats = GetMaxTeamSeats(tier),
            },
        };
    }

    private static int GetMaxTeamSeats(string tier) =>
        tier switch
        {
            WalletConstants.BusinessTier => 5,
            WalletConstants.EnterpriseTier => 50,
            _ => 1,
        };
}
