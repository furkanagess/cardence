using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using FluentAssertions;
using NSubstitute;
using Xunit;

namespace Cardence.Tests.Services;

public sealed class PlanPolicyServiceTests
{
    private readonly IWalletEntitlementRepository _walletRepository =
        Substitute.For<IWalletEntitlementRepository>();
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly PlanPolicyService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public PlanPolicyServiceTests()
    {
        _currentUser.GetRequiredUserId().Returns(_userId);
        _service = new PlanPolicyService(_walletRepository, _currentUser);
    }

    [Fact]
    public async Task GetEntitlementsAsync_ReturnsFreeLimits_WhenUserIsFree()
    {
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.FreeTier,
                MaxCards = WalletConstants.FreeMaxCards,
            });

        var result = await _service.GetEntitlementsAsync();

        result.Tier.Should().Be(WalletConstants.FreeTier);
        result.Features.AdsDisabled.Should().BeFalse();
        result.Features.AdvancedDesigns.Should().BeFalse();
        result.Features.CsvExport.Should().BeFalse();
        result.Features.CrmIntegration.Should().BeFalse();
        result.Limits.MaxBusinessCards.Should().Be(WalletConstants.FreeMaxBusinessCards);
        result.Limits.MaxSavedCards.Should().BeNull();
        result.Limits.MaxEventGroups.Should().Be(WalletConstants.FreeMaxEventGroups);
        result.Limits.MaxTeamSeats.Should().Be(1);
    }

    [Fact]
    public async Task GetEntitlementsAsync_ReturnsPremiumFeatures_WhenUserIsPremium()
    {
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.PremiumTier,
                MaxCards = WalletConstants.PremiumMaxCards,
            });

        var result = await _service.GetEntitlementsAsync();

        result.Tier.Should().Be(WalletConstants.PremiumTier);
        result.Features.AdsDisabled.Should().BeTrue();
        result.Features.AdvancedDesigns.Should().BeTrue();
        result.Features.ProfileStats.Should().BeTrue();
        result.Features.CsvExport.Should().BeTrue();
        result.Features.NetworkGraph.Should().BeTrue();
        result.Features.WalletPass.Should().BeTrue();
        result.Features.CrmIntegration.Should().BeFalse();
        result.Limits.MaxBusinessCards.Should().Be(WalletConstants.PremiumMaxBusinessCards);
        result.Limits.MaxSavedCards.Should().BeNull();
        result.Limits.MaxEventGroups.Should().BeNull();
        result.Limits.MaxTeamSeats.Should().Be(1);
    }
}
