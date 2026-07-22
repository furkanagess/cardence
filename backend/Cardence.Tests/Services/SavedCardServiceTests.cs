using Cardence.Application.Common;
using Cardence.Application.DTOs.Wallet;
using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentAssertions;
using FluentValidation;
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
    private readonly IWalletCardInviteRepository _walletCardInviteRepository =
        Substitute.For<IWalletCardInviteRepository>();
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
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.FreeTier,
                MaxCards = WalletConstants.FreeMaxCards,
            });
        _service = new SavedCardService(
            _savedCardRepository,
            _businessCardRepository,
            _walletRepository,
            _eventGroupRepository,
            _walletCardInviteRepository,
            _ownerPremiumSync,
            _currentUser,
            Substitute.For<IPushNotificationService>(),
            Substitute.For<IUserRepository>(),
            Substitute.For<IValidator<RespondWalletCardInvitationRequest>>(),
            Substitute.For<Microsoft.Extensions.Logging.ILogger<SavedCardService>>());
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
    public async Task UpgradeWalletPlanAsync_GrantsPremiumAndSyncsOwnerFlag()
    {
        _walletRepository.UpgradeToPremiumAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.PremiumTier,
                MaxCards = WalletConstants.PremiumMaxCards,
            });
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
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

    [Fact]
    public async Task CreateFromJsonAsync_CreatesReciprocalInvite_WhenSaverHasOwnCard()
    {
        const string ownerCardId = "111111";
        const string saverCardId = "222222";
        var ownerUserId = Guid.NewGuid();
        var saverCardEntityId = Guid.NewGuid();

        _savedCardRepository.GetByUserAndCardIdAsync(_userId, ownerCardId, Arg.Any<CancellationToken>())
            .Returns((SavedCard?)null);
        _savedCardRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(0);
        _businessCardRepository.GetByCardIdAsync(ownerCardId, Arg.Any<CancellationToken>())
            .Returns(new Card
            {
                Id = Guid.NewGuid(),
                UserId = ownerUserId,
                CardId = ownerCardId,
                DisplayName = "Owner Card",
                Email = "owner@example.com",
            });
        _businessCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([
                new Card
                {
                    Id = saverCardEntityId,
                    UserId = _userId,
                    CardId = saverCardId,
                    DisplayName = "Saver Card",
                },
            ]);
        _savedCardRepository.GetByUserAndCardIdAsync(ownerUserId, saverCardId, Arg.Any<CancellationToken>())
            .Returns((SavedCard?)null);
        _walletCardInviteRepository
            .UpsertPendingAsync(Arg.Any<WalletCardInvite>(), Arg.Any<CancellationToken>())
            .Returns(ci => ci.ArgAt<WalletCardInvite>(0).Id);

        var body = System.Text.Json.JsonDocument.Parse(
            $$"""{"cardId":"{{ownerCardId}}","displayName":"Owner Card","email":"owner@example.com"}""")
            .RootElement;

        await _service.CreateFromJsonAsync(body);

        await _walletCardInviteRepository.Received(1).UpsertPendingAsync(
            Arg.Is<WalletCardInvite>(invite =>
                invite.InviteeUserId == ownerUserId &&
                invite.InviterUserId == _userId &&
                invite.ProposedCardId == saverCardId &&
                invite.ProposedCardEntityId == saverCardEntityId &&
                invite.SavedCardId == ownerCardId &&
                invite.Status == EventGroupInvitationStatuses.Pending),
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task CreateFromJsonAsync_SkipsReciprocalInvite_WhenSaverHasNoOwnCard()
    {
        const string ownerCardId = "333333";
        var ownerUserId = Guid.NewGuid();

        _savedCardRepository.GetByUserAndCardIdAsync(_userId, ownerCardId, Arg.Any<CancellationToken>())
            .Returns((SavedCard?)null);
        _savedCardRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(0);
        _businessCardRepository.GetByCardIdAsync(ownerCardId, Arg.Any<CancellationToken>())
            .Returns(new Card
            {
                Id = Guid.NewGuid(),
                UserId = ownerUserId,
                CardId = ownerCardId,
                DisplayName = "Owner Card",
                Email = "owner@example.com",
            });
        _businessCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([]);

        var body = System.Text.Json.JsonDocument.Parse(
            $$"""{"cardId":"{{ownerCardId}}","displayName":"Owner Card","email":"owner@example.com"}""")
            .RootElement;

        await _service.CreateFromJsonAsync(body);

        await _walletCardInviteRepository.DidNotReceiveWithAnyArgs()
            .UpsertPendingAsync(Arg.Any<WalletCardInvite>(), Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task AcceptInvitationAsync_AddsProposedCardToWallet()
    {
        var invitationId = Guid.NewGuid();
        var inviterUserId = Guid.NewGuid();
        var proposedCard = new Card
        {
            Id = Guid.NewGuid(),
            UserId = inviterUserId,
            CardId = "444444",
            DisplayName = "Inviter",
            Email = "inviter@example.com",
        };
        var invitation = new WalletCardInvite
        {
            Id = invitationId,
            InviterUserId = inviterUserId,
            InviteeUserId = _userId,
            ProposedCardEntityId = proposedCard.Id,
            ProposedCardId = proposedCard.CardId,
            SavedCardId = "555555",
            Status = EventGroupInvitationStatuses.Pending,
            CreatedAtUtc = DateTime.UtcNow,
            ExpiresAtUtc = DateTime.UtcNow.AddDays(7),
            ProposedCard = proposedCard,
        };

        _walletCardInviteRepository.GetForInviteeAsync(
                _userId,
                invitationId,
                Arg.Any<CancellationToken>())
            .Returns(invitation);
        _savedCardRepository.GetByUserAndCardIdAsync(
                _userId,
                proposedCard.CardId,
                Arg.Any<CancellationToken>())
            .Returns((SavedCard?)null);
        _savedCardRepository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(1);

        await _service.AcceptInvitationAsync(new RespondWalletCardInvitationRequest
        {
            Id = invitationId.ToString(),
        });

        await _savedCardRepository.Received(1).AddAsync(
            Arg.Is<SavedCard>(card =>
                card.UserId == _userId &&
                card.CardId == proposedCard.CardId &&
                card.DisplayName == proposedCard.DisplayName),
            Arg.Any<CancellationToken>());
        invitation.Status.Should().Be(EventGroupInvitationStatuses.Accepted);
        await _walletCardInviteRepository.Received(1)
            .SaveChangesAsync(Arg.Any<CancellationToken>());
        await _walletCardInviteRepository.DidNotReceiveWithAnyArgs()
            .UpsertPendingAsync(Arg.Any<WalletCardInvite>(), Arg.Any<CancellationToken>());
    }
}
