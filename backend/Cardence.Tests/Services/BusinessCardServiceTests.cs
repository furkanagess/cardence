using Cardence.Application.DTOs.Cards;
using Xunit;
using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using Cardence.Application.Validators;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentAssertions;
using NSubstitute;

namespace Cardence.Tests.Services;

public sealed class BusinessCardServiceTests
{
    private readonly IBusinessCardRepository _repository = Substitute.For<IBusinessCardRepository>();
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly BusinessCardService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public BusinessCardServiceTests()
    {
        _currentUser.GetRequiredUserId().Returns(_userId);
        _service = new BusinessCardService(
            _repository,
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

        result.CardId.Should().NotBeNullOrWhiteSpace();
        await _repository.Received(1).AddAsync(
            Arg.Is<BusinessCard>(card => card.UserId == _userId),
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task CreateAsync_ThrowsConflict_WhenCardIdExists()
    {
        var request = ValidCardRequest(cardId: "existing-card-id-123");

        _repository.CardIdExistsAsync("existing-card-id-123", null, Arg.Any<CancellationToken>())
            .Returns(true);

        var act = () => _service.CreateAsync(request);

        await act.Should().ThrowAsync<ConflictException>();
    }

    [Fact]
    public async Task UpsertAsync_UpdatesExistingCard()
    {
        var cardId = "my-card-id-12345";
        var existing = new BusinessCard
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
            .Returns(new BusinessCard
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
