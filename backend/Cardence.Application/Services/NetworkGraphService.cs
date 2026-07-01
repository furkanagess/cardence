using Cardence.Application.DTOs.NetworkGraph;
using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using Cardence.Domain.Graph;

namespace Cardence.Application.Services;

public sealed class NetworkGraphService : INetworkGraphService
{
    private const int AbsoluteMaxNodes = 500;

    private readonly ICurrentUserService _currentUser;
    private readonly IBusinessCardRepository _businessCardRepository;
    private readonly ISavedCardRepository _savedCardRepository;
    private readonly IEventGroupRepository _eventGroupRepository;
    private readonly ICardInteractionRepository _cardInteractionRepository;

    public NetworkGraphService(
        ICurrentUserService currentUser,
        IBusinessCardRepository businessCardRepository,
        ISavedCardRepository savedCardRepository,
        IEventGroupRepository eventGroupRepository,
        ICardInteractionRepository cardInteractionRepository)
    {
        _currentUser = currentUser;
        _businessCardRepository = businessCardRepository;
        _savedCardRepository = savedCardRepository;
        _eventGroupRepository = eventGroupRepository;
        _cardInteractionRepository = cardInteractionRepository;
    }

    public async Task<NetworkGraphDto> GetGraphAsync(
        NetworkGraphQuery query,
        CancellationToken cancellationToken = default)
    {
        return query.Scope switch
        {
            GraphScope.Event => await BuildEventGraphAsync(query, cancellationToken),
            GraphScope.Organization => EmptyGraph(query.Scope, query.CenterCardId),
            _ => await BuildPersonalGraphAsync(query, cancellationToken),
        };
    }

    public async Task<NetworkGraphPathDto> GetPathAsync(
        string fromCardId,
        string toCardId,
        GraphScope scope = GraphScope.Personal,
        CancellationToken cancellationToken = default)
    {
        var graph = await GetGraphAsync(
            new NetworkGraphQuery
            {
                Scope = scope,
                MaxDepth = 8,
                MaxNodes = AbsoluteMaxNodes,
            },
            cancellationToken);

        var source = GraphNodeIds.Card(fromCardId.Trim());
        var target = GraphNodeIds.Card(toCardId.Trim());
        var pathNodeIds = FindShortestUndirectedPath(graph.Edges, source, target);
        if (pathNodeIds.Count == 0)
        {
            return new NetworkGraphPathDto
            {
                Found = false,
            };
        }

        var pathNodeSet = pathNodeIds.ToHashSet(StringComparer.Ordinal);
        var pathEdges = graph.Edges
            .Where(edge => pathNodeSet.Contains(edge.Source) && pathNodeSet.Contains(edge.Target))
            .Where(edge => AreAdjacentInPath(pathNodeIds, edge.Source, edge.Target))
            .ToList();

        return new NetworkGraphPathDto
        {
            Found = true,
            Length = Math.Max(0, pathNodeIds.Count - 1),
            Nodes = graph.Nodes
                .Where(node => pathNodeSet.Contains(node.Id))
                .ToList(),
            Edges = pathEdges,
            PathNodeIds = pathNodeIds,
        };
    }

    private async Task<NetworkGraphDto> BuildPersonalGraphAsync(
        NetworkGraphQuery query,
        CancellationToken cancellationToken)
    {
        var userId = _currentUser.GetRequiredUserId();
        var graph = new GraphAccumulator(query.CenterCardId);

        var ownCards = await _businessCardRepository.GetByUserIdAsync(userId, cancellationToken);
        var savedCards = await _savedCardRepository.GetByUserIdAsync(userId, cancellationToken);
        var eventGroups = await _eventGroupRepository.GetByUserIdAsync(userId, cancellationToken);
        var interactions = await _cardInteractionRepository.GetByTargetCardEntityIdsAsync(
            ownCards.Select(card => card.Id).ToList(),
            cancellationToken);

        var hubOwnCard = ResolveHubOwnCard(ownCards, query.CenterCardId);
        var hubNodeId = hubOwnCard is null ? null : GraphNodeIds.Card(hubOwnCard.CardId);
        var useDefaultCenter = query.CenterCardId is null;

        foreach (var card in ownCards)
        {
            var isHub = hubOwnCard is not null && card.Id == hubOwnCard.Id;
            AddBusinessCardNode(
                graph,
                card,
                isOwnCard: true,
                isCenter: isHub && (useDefaultCenter || !string.IsNullOrWhiteSpace(query.CenterCardId)));
            AddCompanyLink(graph, GraphNodeIds.Card(card.CardId), card.Company);
        }

        foreach (var card in ownCards.Where(card => hubOwnCard is null || card.Id != hubOwnCard.Id))
        {
            if (hubNodeId is null)
            {
                continue;
            }

            graph.AddEdge(
                hubNodeId,
                GraphNodeIds.Card(card.CardId),
                "owns",
                GraphEdgeType.Owns);
        }

        // Kullanıcının kaydettiği kişiler (giden bağlantılar).
        foreach (var card in savedCards)
        {
            AddSavedCardNode(graph, card);
            if (hubNodeId is not null)
            {
                graph.AddEdge(hubNodeId, GraphNodeIds.Card(card.CardId), "saved", GraphEdgeType.Saved);
            }

            AddCompanyLink(graph, GraphNodeIds.Card(card.CardId), card.Company);
        }

        AddEventLinks(graph, savedCards, eventGroups);
        await AddReverseSaverLinksAsync(graph, interactions, userId, cancellationToken);

        return graph.ToDto(
            "personal",
            query.MaxNodes,
            query.CenterCardId ?? hubOwnCard?.CardId);
    }

    private static Card? ResolveHubOwnCard(IReadOnlyList<Card> ownCards, string? centerCardId)
    {
        if (ownCards.Count == 0)
        {
            return null;
        }

        if (!string.IsNullOrWhiteSpace(centerCardId))
        {
            var centered = ownCards.FirstOrDefault(card =>
                string.Equals(card.CardId, centerCardId, StringComparison.Ordinal));
            if (centered is not null)
            {
                return centered;
            }
        }

        return ownCards[0];
    }

    /// <summary>
    /// Kullanıcının kartlarını kaydeden kişileri (gelen bağlantılar) gerçek
    /// kart düğümleri olarak ekler.
    /// </summary>
    private async Task AddReverseSaverLinksAsync(
        GraphAccumulator graph,
        IReadOnlyList<CardInteraction> interactions,
        Guid currentUserId,
        CancellationToken cancellationToken)
    {
        var savedInteractions = interactions
            .Where(interaction =>
                interaction.EventType == CardInteractionTypes.CardSaved &&
                interaction.ActorUserId.HasValue &&
                interaction.ActorUserId.Value != currentUserId)
            .ToList();

        if (savedInteractions.Count == 0)
        {
            return;
        }

        var actorUserIds = savedInteractions
            .Select(interaction => interaction.ActorUserId!.Value)
            .Distinct()
            .ToList();

        var actorCards = await _businessCardRepository.GetByUserIdsAsync(
            actorUserIds,
            cancellationToken);

        // Her kaydeden için temsilci kart (en çok kaydedilen / en güncel).
        var representativeByUser = actorCards
            .GroupBy(card => card.UserId)
            .ToDictionary(group => group.Key, group => group.First());

        foreach (var interaction in savedInteractions)
        {
            if (!representativeByUser.TryGetValue(interaction.ActorUserId!.Value, out var saverCard))
            {
                continue;
            }

            AddBusinessCardNode(graph, saverCard, isOwnCard: false);
            AddCompanyLink(graph, GraphNodeIds.Card(saverCard.CardId), saverCard.Company);
            graph.AddEdge(
                GraphNodeIds.Card(saverCard.CardId),
                GraphNodeIds.Card(interaction.TargetCardPublicId),
                "saved_by",
                GraphEdgeType.SavedBy,
                occurredAt: interaction.OccurredAt);
        }
    }

    private async Task<NetworkGraphDto> BuildEventGraphAsync(
        NetworkGraphQuery query,
        CancellationToken cancellationToken)
    {
        if (query.EventGroupId is null)
        {
            throw new NotFoundException("EventGroup", "missing");
        }

        var userId = _currentUser.GetRequiredUserId();
        var eventGroup = await _eventGroupRepository.GetByUserAndIdAsync(
            userId,
            query.EventGroupId.Value,
            cancellationToken)
            ?? throw new NotFoundException("EventGroup", query.EventGroupId.Value.ToString());

        var cards = await _eventGroupRepository.GetCardsInGroupAsync(
            userId,
            query.EventGroupId.Value,
            cancellationToken);

        var graph = new GraphAccumulator(query.CenterCardId);
        var eventNodeId = GraphNodeIds.Event(eventGroup.Id);
        graph.AddNode(
            eventNodeId,
            "event",
            eventGroup.Name,
            subtitle: eventGroup.Location,
            isCenter: query.CenterCardId is null);

        foreach (var card in cards)
        {
            AddSavedCardNode(graph, card);
            graph.AddEdge(
                GraphNodeIds.Card(card.CardId),
                eventNodeId,
                "met_at_event",
                GraphEdgeType.MetAtEvent,
                eventGroupId: eventGroup.Id);
            AddCompanyLink(graph, GraphNodeIds.Card(card.CardId), card.Company);
        }

        AddSameCompanyLinks(graph, cards);

        return graph.ToDto(
            "event",
            query.MaxNodes,
            query.CenterCardId);
    }

    private static void AddBusinessCardNode(
        GraphAccumulator graph,
        Card card,
        bool isOwnCard,
        bool isCenter = false)
    {
        var label = FirstNonEmpty(card.DisplayName, card.CardName, card.CardId);
        var subtitle = JoinSubtitle(card.Company, card.Title);
        graph.AddNode(
            GraphNodeIds.Card(card.CardId),
            "card",
            label,
            subtitle,
            card.CardId,
            card.Company,
            photoUrl: card.PhotoUrl,
            isCenter: isCenter,
            isOwnCard: isOwnCard);
    }

    private static void AddSavedCardNode(GraphAccumulator graph, SavedCard card)
    {
        var label = FirstNonEmpty(card.DisplayName, card.CardId);
        var subtitle = JoinSubtitle(card.Company, card.Title);
        graph.AddNode(
            GraphNodeIds.Card(card.CardId),
            "card",
            label,
            subtitle,
            card.CardId,
            card.Company,
            photoUrl: card.PhotoUrl);
    }

    private static void AddCompanyLink(GraphAccumulator graph, string cardNodeId, string? company)
    {
        if (string.IsNullOrWhiteSpace(company))
        {
            return;
        }

        var companyNodeId = GraphNodeIds.Company(company);
        graph.AddNode(companyNodeId, "company", company.Trim());
        graph.AddEdge(cardNodeId, companyNodeId, "works_at", GraphEdgeType.WorksAt);
    }

    private static void AddEventLinks(
        GraphAccumulator graph,
        IReadOnlyList<SavedCard> savedCards,
        IReadOnlyList<EventGroup> eventGroups)
    {
        if (savedCards.Count == 0 || eventGroups.Count == 0)
        {
            return;
        }

        var eventsById = eventGroups.ToDictionary(group => group.Id.ToString(), StringComparer.OrdinalIgnoreCase);
        foreach (var card in savedCards)
        {
            foreach (var groupId in card.LinkedEventGroupIds)
            {
                if (!eventsById.TryGetValue(groupId, out var eventGroup))
                {
                    continue;
                }

                var eventNodeId = GraphNodeIds.Event(eventGroup.Id);
                graph.AddNode(eventNodeId, "event", eventGroup.Name, eventGroup.Location);
                graph.AddEdge(
                    GraphNodeIds.Card(card.CardId),
                    eventNodeId,
                    "met_at_event",
                    GraphEdgeType.MetAtEvent,
                    eventGroupId: eventGroup.Id);
            }
        }
    }

    private static void AddSameCompanyLinks(GraphAccumulator graph, IReadOnlyList<SavedCard> cards)
    {
        foreach (var group in cards
                     .Where(card => !string.IsNullOrWhiteSpace(card.Company))
                     .GroupBy(card => GraphNodeIds.NormalizeCompanySlug(card.Company))
                     .Where(group => group.Count() > 1))
        {
            var ordered = group.OrderBy(card => card.CardId, StringComparer.Ordinal).ToList();
            for (var i = 0; i < ordered.Count - 1; i++)
            {
                graph.AddEdge(
                    GraphNodeIds.Card(ordered[i].CardId),
                    GraphNodeIds.Card(ordered[i + 1].CardId),
                    "same_company",
                    GraphEdgeType.SameCompany);
            }
        }
    }

    private static NetworkGraphDto EmptyGraph(GraphScope scope, string? centerCardId) =>
        new()
        {
            Scope = ToApiValue(scope),
            Metrics = new NetworkGraphMetricsDto
            {
                CenterCardId = centerCardId,
            },
        };

    private static string ToApiValue(GraphScope scope) =>
        scope switch
        {
            GraphScope.Event => "event",
            GraphScope.Organization => "organization",
            _ => "personal",
        };

    private static string FirstNonEmpty(params string?[] values) =>
        values.FirstOrDefault(value => !string.IsNullOrWhiteSpace(value))?.Trim() ?? string.Empty;

    private static string? JoinSubtitle(params string?[] values)
    {
        var parts = values
            .Where(value => !string.IsNullOrWhiteSpace(value))
            .Select(value => value!.Trim())
            .ToList();

        return parts.Count == 0 ? null : string.Join(" · ", parts);
    }

    private static IReadOnlyList<string> FindShortestUndirectedPath(
        IReadOnlyList<GraphEdgeDto> edges,
        string source,
        string target)
    {
        if (source == target)
        {
            return [source];
        }

        var adjacency = new Dictionary<string, List<string>>(StringComparer.Ordinal);
        foreach (var edge in edges)
        {
            AddAdjacent(adjacency, edge.Source, edge.Target);
            AddAdjacent(adjacency, edge.Target, edge.Source);
        }

        var queue = new Queue<string>();
        var visited = new HashSet<string>(StringComparer.Ordinal) { source };
        var previous = new Dictionary<string, string>(StringComparer.Ordinal);
        queue.Enqueue(source);

        while (queue.Count > 0)
        {
            var current = queue.Dequeue();
            if (!adjacency.TryGetValue(current, out var nextNodes))
            {
                continue;
            }

            foreach (var next in nextNodes)
            {
                if (!visited.Add(next))
                {
                    continue;
                }

                previous[next] = current;
                if (next == target)
                {
                    return ReconstructPath(previous, source, target);
                }

                queue.Enqueue(next);
            }
        }

        return [];
    }

    private static void AddAdjacent(Dictionary<string, List<string>> adjacency, string source, string target)
    {
        if (!adjacency.TryGetValue(source, out var nodes))
        {
            nodes = [];
            adjacency[source] = nodes;
        }

        nodes.Add(target);
    }

    private static IReadOnlyList<string> ReconstructPath(
        IReadOnlyDictionary<string, string> previous,
        string source,
        string target)
    {
        var path = new List<string> { target };
        var current = target;
        while (current != source)
        {
            if (!previous.TryGetValue(current, out current!))
            {
                return [];
            }

            path.Add(current);
        }

        path.Reverse();
        return path;
    }

    private static bool AreAdjacentInPath(IReadOnlyList<string> pathNodeIds, string source, string target)
    {
        for (var i = 0; i < pathNodeIds.Count - 1; i++)
        {
            if ((pathNodeIds[i] == source && pathNodeIds[i + 1] == target) ||
                (pathNodeIds[i] == target && pathNodeIds[i + 1] == source))
            {
                return true;
            }
        }

        return false;
    }

    private sealed class GraphAccumulator
    {
        private readonly Dictionary<string, MutableNode> _nodes = new(StringComparer.Ordinal);
        private readonly Dictionary<string, MutableEdge> _edges = new(StringComparer.Ordinal);
        private readonly string? _centerCardId;

        public GraphAccumulator(string? centerCardId)
        {
            _centerCardId = centerCardId;
        }

        public void AddNode(
            string id,
            string type,
            string label,
            string? subtitle = null,
            string? cardId = null,
            string? company = null,
            string? photoUrl = null,
            bool isCenter = false,
            bool isOwnCard = false)
        {
            if (_nodes.TryGetValue(id, out var existing))
            {
                existing.IsCenter = existing.IsCenter || isCenter || IsCenterCard(cardId);
                existing.IsOwnCard = existing.IsOwnCard || isOwnCard;
                if (string.IsNullOrWhiteSpace(existing.PhotoUrl) && !string.IsNullOrWhiteSpace(photoUrl))
                {
                    existing.PhotoUrl = photoUrl;
                }
                return;
            }

            _nodes[id] = new MutableNode
            {
                Id = id,
                Type = type,
                Label = string.IsNullOrWhiteSpace(label) ? id : label,
                Subtitle = subtitle,
                CardId = cardId,
                Company = company,
                PhotoUrl = photoUrl,
                IsCenter = isCenter || IsCenterCard(cardId),
                IsOwnCard = isOwnCard,
            };
        }

        public void AddEdge(
            string source,
            string target,
            string type,
            GraphEdgeType edgeType,
            DateTime? occurredAt = null,
            Guid? eventGroupId = null,
            Guid? organizationEventId = null)
        {
            if (!_nodes.ContainsKey(source) || !_nodes.ContainsKey(target))
            {
                return;
            }

            var id = GraphNodeIds.Edge(edgeType, source, target);
            if (_edges.TryGetValue(id, out var edge))
            {
                edge.Weight++;
                edge.OccurredAt = Max(edge.OccurredAt, occurredAt);
                return;
            }

            _edges[id] = new MutableEdge
            {
                Id = id,
                Source = source,
                Target = target,
                Type = type,
                Weight = 1,
                OccurredAt = occurredAt,
                EventGroupId = eventGroupId,
                OrganizationEventId = organizationEventId,
            };

            _nodes[source].Degree++;
            _nodes[target].Degree++;
        }

        public NetworkGraphDto ToDto(string scope, int maxNodes, string? centerCardId)
        {
            var take = Math.Clamp(maxNodes <= 0 ? 100 : maxNodes, 1, AbsoluteMaxNodes);
            var selectedNodes = _nodes.Values
                .OrderByDescending(node => node.IsCenter)
                .ThenByDescending(node => node.IsOwnCard)
                .ThenByDescending(node => node.Degree)
                .ThenBy(node => node.Label, StringComparer.OrdinalIgnoreCase)
                .Take(take)
                .ToList();

            var selectedNodeIds = selectedNodes
                .Select(node => node.Id)
                .ToHashSet(StringComparer.Ordinal);

            var selectedEdges = _edges.Values
                .Where(edge => selectedNodeIds.Contains(edge.Source) && selectedNodeIds.Contains(edge.Target))
                .OrderByDescending(edge => edge.Weight)
                .ThenBy(edge => edge.Type, StringComparer.Ordinal)
                .Select(edge => edge.ToDto())
                .ToList();

            return new NetworkGraphDto
            {
                Scope = scope,
                Nodes = selectedNodes.Select(node => node.ToDto()).ToList(),
                Edges = selectedEdges,
                Metrics = new NetworkGraphMetricsDto
                {
                    NodeCount = selectedNodes.Count,
                    EdgeCount = selectedEdges.Count,
                    CenterCardId = centerCardId,
                },
            };
        }

        private bool IsCenterCard(string? cardId) =>
            !string.IsNullOrWhiteSpace(_centerCardId) &&
            string.Equals(cardId, _centerCardId, StringComparison.Ordinal);

        private static DateTime? Max(DateTime? left, DateTime? right)
        {
            if (left is null)
            {
                return right;
            }

            if (right is null)
            {
                return left;
            }

            return left > right ? left : right;
        }
    }

    private sealed class MutableNode
    {
        public required string Id { get; init; }
        public required string Type { get; init; }
        public required string Label { get; init; }
        public string? Subtitle { get; init; }
        public string? CardId { get; init; }
        public string? Company { get; init; }
        public string? PhotoUrl { get; set; }
        public int Degree { get; set; }
        public bool IsCenter { get; set; }
        public bool IsOwnCard { get; set; }

        public GraphNodeDto ToDto() =>
            new()
            {
                Id = Id,
                Type = Type,
                Label = Label,
                Subtitle = Subtitle,
                CardId = CardId,
                Company = Company,
                PhotoUrl = PhotoUrl,
                Degree = Degree,
                IsCenter = IsCenter,
                IsOwnCard = IsOwnCard,
            };
    }

    private sealed class MutableEdge
    {
        public required string Id { get; init; }
        public required string Source { get; init; }
        public required string Target { get; init; }
        public required string Type { get; init; }
        public int Weight { get; set; }
        public DateTime? OccurredAt { get; set; }
        public Guid? EventGroupId { get; init; }
        public Guid? OrganizationEventId { get; init; }

        public GraphEdgeDto ToDto() =>
            new()
            {
                Id = Id,
                Source = Source,
                Target = Target,
                Type = Type,
                Weight = Weight,
                OccurredAt = OccurredAt,
                EventGroupId = EventGroupId,
                OrganizationEventId = OrganizationEventId,
            };
    }
}
