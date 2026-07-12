using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentAssertions;
using NSubstitute;
using Xunit;

namespace Cardence.Tests.Services;

public sealed class SavedCardServiceTests
{
    private readonly ISavedCardRepository _savedCardRepository =
        Substitute.For<ISavedCardRepository>();
    private readonly IBusinessCardRepository _businessCardRepository =
        Substitute.For<IBusinessCardRepository>();
    private readonly IWalletEntitlementRepository _walletRepository =
        Substitute.For<IWalletEntitlementRepository>();
    private readonly IEventGroupRepository _eventGroupRepository =
        Substitute.For<IEventGroupRepository>();
    private readonly ICardInteractionRepository _cardInteractionRepository =
        Substitute.For<ICardInteractionRepository>();
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly IWalletOwnerPremiumSyncService _ownerPremiumSync =
        Substitute.For<IWalletOwnerPremiumSyncService>();
    private readonly SavedCardService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public SavedCardServiceTests()
    {
        _currentUser.GetRequiredUserId().Returns(_userId);
        _savedCardRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(3);
        _businessCardRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(1);
        _eventGroupRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(1);
        _service = new SavedCardService(
            _savedCardRepository,
            _businessCardRepository,
            _walletRepository,
            _eventGroupRepository,
            _cardInteractionRepository,
            _ownerPremiumSync,
            _currentUser);
    }

    [Fact]
    public async Task GetWalletQuotaAsync_ReturnsFreePlanBusinessCardLimit()
    {
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.FreeTier,
                MaxCards = WalletConstants.FreeMaxCards,
            });

        var quota = await _service.GetWalletQuotaAsync();

        quota.Tier.Should().Be(WalletConstants.FreeTier);
        quota.UsedCount.Should().Be(3);
        quota.MaxCards.Should().Be(WalletConstants.FreeMaxCards);
        quota.CanAddMore.Should().BeTrue();
        quota.Remaining.Should().Be(12);
        quota.BusinessCardCount.Should().Be(1);
        quota.MaxBusinessCards.Should().Be(WalletConstants.FreeMaxBusinessCards);
        quota.CanAddBusinessCard.Should().BeTrue();
        quota.EventGroupCount.Should().Be(1);
        quota.MaxEventGroups.Should().Be(WalletConstants.FreeMaxEventGroups);
        quota.CanAddEventGroup.Should().BeTrue();
    }

    [Fact]
    public async Task GetWalletQuotaAsync_ReturnsPremiumUnlimitedEventGroups()
    {
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.PremiumTier,
                MaxCards = WalletConstants.PremiumMaxCards,
            });
        _businessCardRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(WalletConstants.FreeMaxBusinessCards);
        _eventGroupRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(WalletConstants.FreeMaxEventGroups);

        var quota = await _service.GetWalletQuotaAsync();

        quota.Tier.Should().Be(WalletConstants.PremiumTier);
        quota.MaxCards.Should().Be(WalletConstants.PremiumMaxCards);
        quota.CanAddMore.Should().BeTrue();
        quota.MaxBusinessCards.Should().Be(WalletConstants.PremiumMaxBusinessCards);
        quota.CanAddBusinessCard.Should().BeTrue();
        quota.MaxEventGroups.Should().Be(0);
        quota.CanAddEventGroup.Should().BeTrue();
    }

    [Fact]
    public async Task UpgradeWalletPlanAsync_UpgradesFreeTierToPremium()
    {
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(
                new WalletEntitlement
                {
                    UserId = _userId,
                    Tier = WalletConstants.FreeTier,
                    MaxCards = WalletConstants.FreeMaxCards,
                },
                new WalletEntitlement
                {
                    UserId = _userId,
                    Tier = WalletConstants.PremiumTier,
                    MaxCards = WalletConstants.PremiumMaxCards,
                });
        _walletRepository.UpgradeToPremiumAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.PremiumTier,
                MaxCards = WalletConstants.PremiumMaxCards,
            });

        var quota = await _service.UpgradeWalletPlanAsync();

        quota.Tier.Should().Be(WalletConstants.PremiumTier);
        await _walletRepository.Received(1).UpgradeToPremiumAsync(
            _userId,
            Arg.Any<CancellationToken>());
        await _ownerPremiumSync.Received(1).SyncForUserAsync(
            _userId,
            WalletConstants.PremiumTier,
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task CreateFromJsonAsync_RejectsOwnBusinessCard()
    {
        const string cardId = "123456";
        _savedCardRepository.GetByUserAndCardIdAsync(_userId, cardId, Arg.Any<CancellationToken>())
            .Returns((SavedCard?)null);
        _businessCardRepository.GetByCardIdAsync(cardId, Arg.Any<CancellationToken>())
            .Returns(new Card
            {
                Id = Guid.NewGuid(),
                UserId = _userId,
                CardId = cardId,
                DisplayName = "Own Card",
            });

        var body = System.Text.Json.JsonDocument.Parse(
            $$"""{"cardId":"{{cardId}}","displayName":"Own Card"}""").RootElement;

        var act = () => _service.CreateFromJsonAsync(body);

        var exception = await act.Should().ThrowAsync<ConflictException>();
        exception.Which.Code.Should().Be(ErrorCodes.WalletOwnCardForbidden);
        await _savedCardRepository.DidNotReceiveWithAnyArgs()
            .AddAsync(Arg.Any<SavedCard>(), Arg.Any<CancellationToken>());
    }
}
