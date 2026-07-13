using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;

namespace Cardence.Application.Common;

internal static class CardInteractionWriter
{
    public static Task LogCardCreatedAsync(
        ICardInteractionRepository repository,
        Card card,
        Guid actorUserId,
        string source,
        DateTime occurredAt,
        CancellationToken cancellationToken = default)
    {
        return repository.AddAsync(
            new CardInteraction
            {
                Id = Guid.NewGuid(),
                ActorUserId = actorUserId,
                TargetCardEntityId = card.Id,
                TargetCardPublicId = card.CardId,
                EventType = CardInteractionTypes.CardCreated,
                Source = source,
                OccurredAt = occurredAt,
            },
            cancellationToken);
    }
}
