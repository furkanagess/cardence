using Cardence.Application.DTOs.NetworkGraph;
using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Graph;
using FluentAssertions;
using NSubstitute;
using Xunit;

namespace Cardence.Tests.Services;

public sealed class NetworkGraphServiceTests
{
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly IBusinessCardRepository _businessCardRepository =
        Substitute.For<IBusinessCardRepository>();
    private readonly ISavedCardRepository _savedCardRepository =
        Substitute.For<ISavedCardRepository>();
    private readonly IEventGroupRepository _eventGroupRepository =
        Substitute.For<IEventGroupRepository>();
    private readonly NetworkGraphService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public NetworkGraphServiceTests()
    {
        _currentUser.GetRequiredUserId().Returns(_userId);
        _service = new NetworkGraphService(
            _currentUser,
            _businessCardRepository,
            _savedCardRepository,
            _eventGroupRepository);
    }

    [Fact]
    public async Task GetGraphAsync_BuildsPersonalGraph_WithSavedAndReverseSaverNodes()
    {
        var ownCard = OwnCard("111111", "Acme");
        var savedCard = SavedCard("222222", "Acme");
        var eventGroup = new EventGroup
        {
            Id = Guid.NewGuid(),
            UserId = _userId,
            Name = "Web Summit",
            Location = "Lisbon",
            CreatedAt = DateTime.UtcNow,
        };
        savedCard.LinkedEventGroupIds = [eventGroup.Id.ToString()];

        var saverUserId = Guid.NewGuid();
        var saverCard = new Card
        {
            Id = Guid.NewGuid(),
            UserId = saverUserId,
            CardId = "999999",
            DisplayName = "Saver 999999",
            Company = "Globex",
            Title = "Recruiter",
            PhotoUrl = "https://cdn.example/avatar.png",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };

        _businessCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([ownCard]);
        _savedCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([savedCard]);
        _eventGroupRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([eventGroup]);
        _savedCardRepository.GetByTargetCardPublicIdsAsync(
                Arg.Is<IReadOnlyCollection<string>>(ids => ids.Contains(ownCard.CardId)),
                Arg.Any<CancellationToken>())
            .Returns([
                new SavedCard
                {
                    UserId = saverUserId,
                    CardId = ownCard.CardId,
                    SavedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow,
                },
            ]);
        _businessCardRepository.GetByUserIdsAsync(
                Arg.Is<IReadOnlyCollection<Guid>>(ids => ids.Contains(saverUserId)),
                Arg.Any<CancellationToken>())
            .Returns([saverCard]);

        var graph = await _service.GetGraphAsync(
            new NetworkGraphQuery
            {
                CenterCardId = ownCard.CardId,
            });

        graph.Scope.Should().Be("personal");
        graph.Nodes.Should().Contain(node =>
            node.Id == GraphNodeIds.Card("111111") &&
            node.IsOwnCard &&
            node.IsCenter);
        graph.Nodes.Should().NotContain(node => node.Type == "user");
        graph.Nodes.Should().Contain(node => node.Id == GraphNodeIds.Card("222222"));
        graph.Nodes.Should().Contain(node =>
            node.Id == GraphNodeIds.Card("999999") &&
            node.PhotoUrl == "https://cdn.example/avatar.png");
        graph.Nodes.Should().Contain(node => node.Id == GraphNodeIds.Company("Acme"));
        graph.Nodes.Should().Contain(node => node.Id == GraphNodeIds.Event(eventGroup.Id));
        graph.Edges.Should().Contain(edge => edge.Type == "saved");
        graph.Edges.Should().Contain(edge => edge.Type == "saved_by");
        graph.Edges.Should().Contain(edge => edge.Type == "works_at");
        graph.Edges.Should().Contain(edge => edge.Type == "met_at_event");
        graph.Metrics.NodeCount.Should().Be(graph.Nodes.Count);
        graph.Metrics.EdgeCount.Should().Be(graph.Edges.Count);
    }

    [Fact]
    public async Task GetPathAsync_ReturnsShortestPath_ThroughWalletOwner()
    {
        var ownCard = OwnCard("111111", "Acme");
        var savedCard = SavedCard("222222", "Acme");

        _businessCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([ownCard]);
        _savedCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([savedCard]);
        _eventGroupRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([]);
        _savedCardRepository.GetByTargetCardPublicIdsAsync(
                Arg.Any<IReadOnlyCollection<string>>(),
                Arg.Any<CancellationToken>())
            .Returns([]);

        var path = await _service.GetPathAsync("111111", "222222");

        path.Found.Should().BeTrue();
        path.Length.Should().Be(1);
        path.PathNodeIds.Should().Equal(
            GraphNodeIds.Card("111111"),
            GraphNodeIds.Card("222222"));
        path.Edges.Should().Contain(edge => edge.Type == "saved");
    }

    [Fact]
    public async Task GetGraphAsync_BuildsEventGraph_WithSameCompanyCluster()
    {
        var eventGroup = new EventGroup
        {
            Id = Guid.NewGuid(),
            UserId = _userId,
            Name = "Founders Meetup",
            Location = "Istanbul",
            CreatedAt = DateTime.UtcNow,
        };
        var first = SavedCard("333333", "Acme");
        var second = SavedCard("444444", "Acme");

        _eventGroupRepository.GetByUserAndIdAsync(
                _userId,
                eventGroup.Id,
                Arg.Any<CancellationToken>())
            .Returns(eventGroup);
        _eventGroupRepository.GetCardsInGroupAsync(
                _userId,
                eventGroup.Id,
                Arg.Any<CancellationToken>())
            .Returns([first, second]);

        var graph = await _service.GetGraphAsync(
            new NetworkGraphQuery
            {
                Scope = GraphScope.Event,
                EventGroupId = eventGroup.Id,
            });

        graph.Scope.Should().Be("event");
        graph.Nodes.Should().Contain(node => node.Id == GraphNodeIds.Event(eventGroup.Id));
        graph.Edges.Count(edge => edge.Type == "met_at_event").Should().Be(2);
        graph.Edges.Should().Contain(edge => edge.Type == "same_company");
    }

    private Card OwnCard(string cardId, string company) =>
        new()
        {
            Id = Guid.NewGuid(),
            UserId = _userId,
            CardId = cardId,
            DisplayName = $"Own {cardId}",
            Company = company,
            Title = "Founder",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };

    private SavedCard SavedCard(string cardId, string company) =>
        new()
        {
            UserId = _userId,
            CardId = cardId,
            DisplayName = $"Saved {cardId}",
            Company = company,
            Title = "Investor",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };
}
