using Cardence.Application.DTOs.EventGroups;
using Cardence.Application.Common;
using Cardence.Domain.Entities;

namespace Cardence.Application.Mapping;

public static class EventGroupMapper
{
    public static EventGroupDto ToDto(
        EventGroup entity,
        int cardCount,
        IReadOnlyList<string>? invalidCardIds = null) => new()
    {
        Id = entity.Id.ToString(),
        Name = entity.Name,
        Location = entity.Location,
        StartAt = entity.StartAtUtc,
        EndAt = entity.EndAtUtc,
        Status = EventGroupStatuses.Resolve(entity.StartAtUtc, entity.EndAtUtc),
        EventDate = entity.EventDate,
        PhotoUrl = entity.PhotoUrl,
        CardCount = cardCount,
        CreatedAt = entity.CreatedAt,
        InvalidCardIds = invalidCardIds ?? [],
    };
}
