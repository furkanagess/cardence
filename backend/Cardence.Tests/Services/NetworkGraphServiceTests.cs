using Cardence.Application.DTOs.NetworkGraph;
using Cardence.Application.DTOs.Plans;
using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using Cardence.Domain.Graph;
using FluentAssertions;
using NSubstitute;
using Xunit;

namespace Cardence.Tests.Services;

public sealed class NetworkGraphServiceTests
{
    private readonly ICurrentUserService _currentUser = Substitute.For<ICurrentUserService>();
    private readonly IPlanPolicyService _planPolicyService = Substitute.For<IPlanPolicyService>();
    private readonly IBusinessCardRepository _businessCardRepository =
        Substitute.For<IBusinessCardRepository>();
    private readonly ISavedCardRepository _savedCardRepository =
        Substitute.For<ISavedCardRepository>();
    private readonly IEventGroupRepository _eventGroupRepository =
        Substitute.For<IEventGroupRepository>();
    private readonly ICardInteractionRepository _cardInteractionRepository =
        Substitute.For<ICardInteractionRepository>();
    private readonly NetworkGraphService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public NetworkGraphServiceTests()
    {
        _currentUser.GetRequiredUserId().Returns(_userId);
        _service = new NetworkGraphService(
            _currentUser,
            _planPolicyService,
            _businessCardRepository,
            _savedCardRepository,
            _eventGroupRepository,
            _cardInteractionRepository);
    }

    [Fact]
    public async Task GetGraphAsync_ThrowsForbidden_WhenNetworkGraphNotIncluded()
    {
        _planPolicyService.GetEntitlementsAsync(Arg.Any<CancellationToken>())
            .Returns(Entitlements(networkGraph: false));

        var act = () => _service.GetGraphAsync(new NetworkGraphQuery());

        var exception = await act.Should().ThrowAsync<ForbiddenException>();
        exception.Which.Code.Should().Be("FEATURE_NOT_INCLUDED");
    }

    [Fact]
    public async Task GetGraphAsync_BuildsPersonalGraph_FromCardsEventsAndInteractions()
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

        _planPolicyService.GetEntitlementsAsync(Arg.Any<CancellationToken>())
            .Returns(Entitlements(networkGraph: true));
        _businessCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([ownCard]);
        _savedCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([savedCard]);
        _eventGroupRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([eventGroup]);
        _cardInteractionRepository.GetByTargetCardEntityIdsAsync(
                Arg.Is<IReadOnlyCollection<Guid>>(ids => ids.Contains(ownCard.Id)),
                Arg.Any<CancellationToken>())
            .Returns([
                Interaction(ownCard, CardInteractionTypes.CardViewed),
                Interaction(ownCard, CardInteractionTypes.CardViewed),
            ]);

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
        graph.Nodes.Should().Contain(node => node.Id == GraphNodeIds.Card("222222"));
        graph.Nodes.Should().Contain(node => node.Id == GraphNodeIds.Company("Acme"));
        graph.Nodes.Should().Contain(node => node.Id == GraphNodeIds.Event(eventGroup.Id));
        graph.Edges.Should().Contain(edge => edge.Type == "owns");
        graph.Edges.Should().Contain(edge => edge.Type == "saved");
        graph.Edges.Should().Contain(edge => edge.Type == "works_at");
        graph.Edges.Should().Contain(edge => edge.Type == "met_at_event");
        graph.Edges.Should().Contain(edge => edge.Type == CardInteractionTypes.CardViewed && edge.Weight == 2);
        graph.Metrics.NodeCount.Should().Be(graph.Nodes.Count);
        graph.Metrics.EdgeCount.Should().Be(graph.Edges.Count);
    }

    [Fact]
    public async Task GetPathAsync_ReturnsShortestPath_ThroughWalletOwner()
    {
        var ownCard = OwnCard("111111", "Acme");
        var savedCard = SavedCard("222222", "Acme");

        _planPolicyService.GetEntitlementsAsync(Arg.Any<CancellationToken>())
            .Returns(Entitlements(networkGraph: true));
        _businessCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([ownCard]);
        _savedCardRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([savedCard]);
        _eventGroupRepository.GetByUserIdAsync(_userId, Arg.Any<CancellationToken>())
            .Returns([]);
        _cardInteractionRepository.GetByTargetCardEntityIdsAsync(
                Arg.Any<IReadOnlyCollection<Guid>>(),
                Arg.Any<CancellationToken>())
            .Returns([]);

        var path = await _service.GetPathAsync("111111", "222222");

        path.Found.Should().BeTrue();
        path.Length.Should().Be(2);
        path.PathNodeIds.Should().Equal(
            GraphNodeIds.Card("111111"),
            GraphNodeIds.User(_userId),
            GraphNodeIds.Card("222222"));
        path.Edges.Should().Contain(edge => edge.Type == "owns");
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

        _planPolicyService.GetEntitlementsAsync(Arg.Any<CancellationToken>())
            .Returns(Entitlements(networkGraph: true));
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

    private static PlanEntitlementsDto Entitlements(bool networkGraph) =>
        new()
        {
            Tier = networkGraph ? WalletConstants.PremiumTier : WalletConstants.FreeTier,
            Features = new PlanFeaturesDto
            {
                NetworkGraph = networkGraph,
            },
            Limits = new PlanLimitsDto(),
        };

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
            Id = Guid.NewGuid(),
            UserId = _userId,
            CardId = cardId,
            DisplayName = $"Saved {cardId}",
            Company = company,
            Title = "Investor",
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow,
        };

    private static CardInteraction Interaction(Card targetCard, string eventType) =>
        new()
        {
            Id = Guid.NewGuid(),
            ActorUserId = null,
            TargetCardEntityId = targetCard.Id,
            TargetCardPublicId = targetCard.CardId,
            EventType = eventType,
            Source = "public",
            OccurredAt = DateTime.UtcNow,
        };
}
