using Cardence.Application.DTOs.EventGroups;
using Cardence.Domain.Entities;

namespace Cardence.Application.Mapping;

public static class EventGroupMapper
{
    public static EventGroupDto ToDto(EventGroup entity, int cardCount) => new()
    {
        Id = entity.Id.ToString(),
        Name = entity.Name,
        CardCount = cardCount,
        CreatedAt = entity.CreatedAt,
    };
}
