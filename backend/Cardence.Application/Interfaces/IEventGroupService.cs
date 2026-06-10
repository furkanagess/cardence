using Cardence.Application.DTOs.EventGroups;
using Cardence.Application.DTOs.Wallet;

namespace Cardence.Application.Interfaces;

public interface IEventGroupService
{
    Task<IReadOnlyList<EventGroupDto>> GetAllAsync(CancellationToken cancellationToken = default);

    Task<EventGroupDto> CreateAsync(
        SaveEventGroupRequest request,
        CancellationToken cancellationToken = default);

    Task<EventGroupDto> UpdateAsync(
        UpdateEventGroupRequest request,
        CancellationToken cancellationToken = default);

    Task DeleteAsync(string groupId, CancellationToken cancellationToken = default);

    Task LinkCardsAsync(
        LinkEventGroupCardsRequest request,
        CancellationToken cancellationToken = default);

    Task UnlinkCardAsync(
        string groupId,
        string cardId,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<SavedCardDto>> GetCardsAsync(
        string groupId,
        CancellationToken cancellationToken = default);
}
