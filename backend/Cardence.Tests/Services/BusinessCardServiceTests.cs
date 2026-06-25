using Cardence.Application.DTOs.Cards;
using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using Cardence.Application.Validators;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentAssertions;
using NSubstitute;
using Xunit;

namespace Cardence.Tests.Services;

public sealed class BusinessCardServiceTests
{
    private readonly IBusinessCardRepository _repository = Substitute.For<IBusinessCardRepository>();
    private readonly IUserRepository _userRepository = Substitute.For<IUserRepository>();
    private readonly IEventGroupRepository _eventGroupRepository =
        Substitute.For<IEventGroupRepository>();
    private readonly IWalletEntitlementRepository _walletRepository =
        Substitute.For<IWalletEntitlementRepository>();
    private readonly ICardInteractionRepository _cardInteractionRepository =
        Substitute.For<ICardInteractionRepository>();
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly BusinessCardService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public BusinessCardServiceTests()
    {
        _currentUser.GetRequiredUserId().Returns(_userId);
        _repository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>()).Returns(0);
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.FreeTier,
                MaxCards = WalletConstants.FreeMaxCards,
            });
        _service = new BusinessCardService(
            _repository,
            _userRepository,
            _eventGroupRepository,
            _walletRepository,
            _cardInteractionRepository,
            _currentUser,
            new BusinessCardDtoValidator());
    }

    [Fact]
    public async Task CreateAsync_GeneratesCardId_WhenMissing()
    {
        var request = ValidCardRequest();

        _repository.CardIdExistsAsync(Arg.Any<string>(), null, Arg.Any<CancellationToken>())
            .Returns(false);

        var result = await _service.CreateAsync(request);

        result.CardId.Should().MatchRegex(@"^\d{6}$");
        await _repository.Received(1).AddAsync(
            Arg.Is<Card>(card => card.UserId == _userId),
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task CreateAsync_ThrowsConflict_WhenCardIdExists()
    {
        var request = ValidCardRequest(cardId: "123456");

        _repository.CardIdExistsAsync("123456", null, Arg.Any<CancellationToken>())
            .Returns(true);

        var act = () => _service.CreateAsync(request);

        await act.Should().ThrowAsync<ConflictException>();
    }

    [Fact]
    public async Task CreateAsync_ThrowsForbidden_WhenFreeBusinessCardLimitReached()
    {
        _repository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(WalletConstants.FreeMaxBusinessCards);

        var act = () => _service.CreateAsync(ValidCardRequest());

        var exception = await act.Should().ThrowAsync<ForbiddenException>();
        exception.Which.Code.Should().Be("PLAN_LIMIT_REACHED");
    }

    [Fact]
    public async Task CreateAsync_AllowsPremiumUser_WhenFreeBusinessCardLimitReached()
    {
        _walletRepository.GetOrCreateAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(new WalletEntitlement
            {
                UserId = _userId,
                Tier = WalletConstants.PremiumTier,
                MaxCards = WalletConstants.PremiumMaxCards,
            });
        _repository.CountByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns(WalletConstants.FreeMaxBusinessCards);
        _repository.CardIdExistsAsync(Arg.Any<string>(), null, Arg.Any<CancellationToken>())
            .Returns(false);

        await _service.CreateAsync(ValidCardRequest());

        await _repository.Received(1).AddAsync(
            Arg.Is<Card>(card => card.UserId == _userId),
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task UpsertAsync_UpdatesExistingCard()
    {
        var cardId = "482917";
        var existing = new Card
        {
            Id = Guid.NewGuid(),
            UserId = _userId,
            CardId = cardId,
            DisplayName = "Old Name",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };

        _repository.GetByUserAndCardIdAsync(_userId, cardId, Arg.Any<CancellationToken>())
            .Returns(existing);

        var request = ValidCardRequest(displayName: "Furkan Çağlar");
        var result = await _service.UpsertAsync(cardId, request);

        result.DisplayName.Should().Be("Furkan Çağlar");
        await _repository.Received(1).UpdateAsync(existing, Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task GetPublicSharePayloadAsync_OmitsEmptyFields()
    {
        var cardId = "public-card-id-123";
        _repository.GetByCardIdAsync(cardId, Arg.Any<CancellationToken>())
            .Returns(new Card
            {
                Id = Guid.NewGuid(),
                UserId = _userId,
                CardId = cardId,
                DisplayName = "Furkan Çağlar",
                Email = "furkan@example.com",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow,
            });

        var payload = await _service.GetPublicSharePayloadAsync(cardId);

        payload.Should().ContainKey("id");
        payload.Should().ContainKey("n");
        payload.Should().ContainKey("e");
        payload.Should().NotContainKey("p");
        await _cardInteractionRepository.Received(1).AddAsync(
            Arg.Is<CardInteraction>(interaction =>
                interaction.TargetCardPublicId == cardId &&
                interaction.EventType == CardInteractionTypes.CardViewed &&
                interaction.Source == "public"),
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task RecordPublicContactClickAsync_WritesContactInteraction()
    {
        var cardId = "482917";
        var card = new Card
        {
            Id = Guid.NewGuid(),
            UserId = _userId,
            CardId = cardId,
            DisplayName = "Furkan Çağlar",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };
        _repository.GetByCardIdAsync(cardId, Arg.Any<CancellationToken>())
            .Returns(card);

        await _service.RecordPublicContactClickAsync(cardId, "linkedin");

        await _cardInteractionRepository.Received(1).AddAsync(
            Arg.Is<CardInteraction>(interaction =>
                interaction.TargetCardEntityId == card.Id &&
                interaction.TargetCardPublicId == cardId &&
                interaction.EventType == CardInteractionTypes.ContactClicked &&
                interaction.Source == "linkedin"),
            Arg.Any<CancellationToken>());
    }

    private static BusinessCardDto ValidCardRequest(
        string? cardId = null,
        string displayName = "Furkan Çağlar") => new()
    {
        CardName = "İş Kartım",
        DisplayName = displayName,
        Email = "furkan@example.com",
        Company = "Cardence",
        Title = "Mobile Developer",
        CardId = cardId,
    };
}
