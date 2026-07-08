using Cardence.Application.DTOs.EventGroups;
using Cardence.Application.DTOs.Wallet;

namespace Cardence.Application.Interfaces;

public interface IEventGroupService
{
    Task<IReadOnlyList<EventGroupDto>> GetAllAsync(CancellationToken cancellationToken = default);

    Task<EventGroupDto> CreateAsync(
        SaveEventGroupRequest request,
        Stream? photoStream = null,
        string? photoContentType = null,
        long photoContentLength = 0,
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

    Task<EventGroupDto> UploadPhotoAsync(
        string groupId,
        Stream photoStream,
        string contentType,
        long contentLength,
        CancellationToken cancellationToken = default);

    Task<EventGroupDto> InviteCardsByCardIdAsync(
        InviteEventGroupCardsByCardIdRequest request,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<EventGroupInvitationDto>> GetPendingInvitationsAsync(
        CancellationToken cancellationToken = default);

    Task AcceptInvitationAsync(
        RespondEventGroupInvitationRequest request,
        CancellationToken cancellationToken = default);

    Task RejectInvitationAsync(
        RespondEventGroupInvitationRequest request,
        CancellationToken cancellationToken = default);
}
