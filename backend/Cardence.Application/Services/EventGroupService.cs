using Cardence.Application.Common;
using Cardence.Application.DTOs.EventGroups;
using Cardence.Application.DTOs.Wallet;
using Cardence.Application.Interfaces;
using Cardence.Application.Mapping;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentValidation;

namespace Cardence.Application.Services;

public sealed class EventGroupService : IEventGroupService
{
    private static readonly HashSet<string> AllowedPhotoContentTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/webp",
    };

    private readonly IEventGroupRepository _eventGroupRepository;
    private readonly IBusinessCardRepository _businessCardRepository;
    private readonly IWalletEntitlementRepository _walletRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IEventGroupPhotoStorage _eventGroupPhotoStorage;
    private readonly IValidator<SaveEventGroupRequest> _saveValidator;
    private readonly IValidator<UpdateEventGroupRequest> _updateValidator;
    private readonly IValidator<LinkEventGroupCardsRequest> _linkValidator;
    private readonly IValidator<InviteEventGroupCardsByCardIdRequest> _inviteByCardIdValidator;
    private readonly IValidator<RespondEventGroupInvitationRequest> _respondInvitationValidator;

    public EventGroupService(
        IEventGroupRepository eventGroupRepository,
        IBusinessCardRepository businessCardRepository,
        IWalletEntitlementRepository walletRepository,
        ICurrentUserService currentUser,
        IEventGroupPhotoStorage eventGroupPhotoStorage,
        IValidator<SaveEventGroupRequest> saveValidator,
        IValidator<UpdateEventGroupRequest> updateValidator,
        IValidator<LinkEventGroupCardsRequest> linkValidator,
        IValidator<InviteEventGroupCardsByCardIdRequest> inviteByCardIdValidator,
        IValidator<RespondEventGroupInvitationRequest> respondInvitationValidator)
    {
        _eventGroupRepository = eventGroupRepository;
        _businessCardRepository = businessCardRepository;
        _walletRepository = walletRepository;
        _currentUser = currentUser;
        _eventGroupPhotoStorage = eventGroupPhotoStorage;
        _saveValidator = saveValidator;
        _updateValidator = updateValidator;
        _linkValidator = linkValidator;
        _inviteByCardIdValidator = inviteByCardIdValidator;
        _respondInvitationValidator = respondInvitationValidator;
    }

    public async Task<IReadOnlyList<EventGroupDto>> GetAllAsync(
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var groups = await _eventGroupRepository.GetByUserIdAsync(userId, cancellationToken);
        var result = new List<EventGroupDto>(groups.Count);

        foreach (var group in groups)
        {
            var cardCount = await _eventGroupRepository.CountCardsInGroupAsync(
                group.Id,
                cancellationToken);
            result.Add(EventGroupMapper.ToDto(group, cardCount));
        }

        return result
            .OrderBy(group => group.Status == EventGroupStatuses.Ended ? 1 : 0)
            .ThenBy(group => group.Status == EventGroupStatuses.Ongoing ? 0 : 1)
            .ThenBy(group => group.Status == EventGroupStatuses.Ended
                ? DateTime.MaxValue.Ticks - (group.EndAt ?? group.StartAt).Ticks
                : group.StartAt.Ticks)
            .ToList();
    }

    public async Task<EventGroupDto> CreateAsync(
        SaveEventGroupRequest request,
        Stream? photoStream = null,
        string? photoContentType = null,
        long photoContentLength = 0,
        CancellationToken cancellationToken = default)
    {
        await _saveValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var name = request.Name.Trim();
        var startAt = NormalizeStartAt(request.StartAt, request.EventDate);
        var endAt = NormalizeEventDate(request.EndAt);
        await EnsureUniqueNameAsync(userId, name, excludeGroupId: null, cancellationToken);
        await EnsureCanCreateEventGroupAsync(userId, cancellationToken);

        var entity = new EventGroup
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Name = name,
            Location = NormalizeOptionalText(request.Location),
            Description = NormalizeOptionalText(request.Description),
            StartAtUtc = startAt,
            EndAtUtc = endAt,
            EventDate = startAt,
            CreatedAt = DateTime.UtcNow,
        };

        await _eventGroupRepository.AddAsync(entity, cancellationToken);

        var invalidCardIds = await _eventGroupRepository.InviteCardsByCardIdsAsync(
            userId,
            entity.Id,
            request.InvitedCardIds,
            cancellationToken);

        if (photoStream is not null)
        {
            await ApplyPhotoAsync(
                entity,
                userId,
                photoStream,
                photoContentType,
                photoContentLength,
                cancellationToken);
        }

        var cardCount = await _eventGroupRepository.CountCardsInGroupAsync(
            entity.Id,
            cancellationToken);

        return EventGroupMapper.ToDto(entity, cardCount, invalidCardIds);
    }

    public async Task<EventGroupDto> UpdateAsync(
        UpdateEventGroupRequest request,
        CancellationToken cancellationToken = default)
    {
        await _updateValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var groupId = ParseGroupId(request.Id);
        var entity = await _eventGroupRepository.GetByUserAndIdAsync(userId, groupId, cancellationToken)
            ?? throw new NotFoundException("EventGroup", request.Id);

        var name = request.Name.Trim();
        var startAt = NormalizeStartAt(request.StartAt, request.EventDate);
        var endAt = NormalizeEventDate(request.EndAt);
        await EnsureUniqueNameAsync(userId, name, excludeGroupId: groupId, cancellationToken);

        entity.Name = name;
        entity.Location = NormalizeOptionalText(request.Location);
        entity.Description = NormalizeOptionalText(request.Description);
        entity.StartAtUtc = startAt;
        entity.EndAtUtc = endAt;
        entity.EventDate = startAt;
        if (request.ClearPhoto)
        {
            await _eventGroupPhotoStorage.DeleteEventGroupPhotoAsync(
                userId,
                entity.Id,
                cancellationToken);
            entity.PhotoUrl = null;
        }
        await _eventGroupRepository.UpdateAsync(entity, cancellationToken);

        var cardCount = await _eventGroupRepository.CountCardsInGroupAsync(
            entity.Id,
            cancellationToken);
        return EventGroupMapper.ToDto(entity, cardCount);
    }

    public async Task DeleteAsync(string groupId, CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var parsedId = ParseGroupId(groupId);
        var entity = await _eventGroupRepository.GetByUserAndIdAsync(userId, parsedId, cancellationToken)
            ?? throw new NotFoundException("EventGroup", groupId);

        if (!string.IsNullOrWhiteSpace(entity.PhotoUrl))
        {
            await _eventGroupPhotoStorage.DeleteEventGroupPhotoAsync(
                userId,
                entity.Id,
                cancellationToken);
        }

        await _eventGroupRepository.DeleteAsync(entity, cancellationToken);
    }

    public async Task LinkCardsAsync(
        LinkEventGroupCardsRequest request,
        CancellationToken cancellationToken = default)
    {
        await _linkValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var groupId = ParseGroupId(request.Id);
        _ = await _eventGroupRepository.GetByUserAndIdAsync(userId, groupId, cancellationToken)
            ?? throw new NotFoundException("EventGroup", request.Id);

        await _eventGroupRepository.LinkCardsAsync(
            userId,
            groupId,
            request.CardIds,
            cancellationToken);
    }

    public async Task UnlinkCardAsync(
        string groupId,
        string cardId,
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var parsedGroupId = ParseGroupId(groupId);
        _ = await _eventGroupRepository.GetByUserAndIdAsync(userId, parsedGroupId, cancellationToken)
            ?? throw new NotFoundException("EventGroup", groupId);

        await _eventGroupRepository.UnlinkCardAsync(
            userId,
            parsedGroupId,
            cardId,
            cancellationToken);
    }

    public async Task<IReadOnlyList<SavedCardDto>> GetCardsAsync(
        string groupId,
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var parsedGroupId = ParseGroupId(groupId);
        _ = await _eventGroupRepository.GetByUserAndIdAsync(userId, parsedGroupId, cancellationToken)
            ?? throw new NotFoundException("EventGroup", groupId);

        var cards = await _eventGroupRepository.GetCardsInGroupAsync(
            userId,
            parsedGroupId,
            cancellationToken);

        await SavedCardEnrichment.HydrateLinkedProfilesAsync(
            cards,
            _businessCardRepository,
            cancellationToken);

        return SavedCardEnrichment
            .SortForWalletDisplay(cards)
            .Select(SavedCardMapper.ToDto)
            .ToList();
    }

    public async Task<EventGroupDto> UploadPhotoAsync(
        string groupId,
        Stream photoStream,
        string contentType,
        long contentLength,
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var parsedGroupId = ParseGroupId(groupId);
        var entity = await _eventGroupRepository.GetByUserAndIdAsync(
                userId,
                parsedGroupId,
                cancellationToken)
            ?? throw new NotFoundException("EventGroup", groupId);

        await ApplyPhotoAsync(
            entity,
            userId,
            photoStream,
            contentType,
            contentLength,
            cancellationToken);

        var cardCount = await _eventGroupRepository.CountCardsInGroupAsync(
            entity.Id,
            cancellationToken);
        return EventGroupMapper.ToDto(entity, cardCount);
    }

    public async Task<EventGroupDto> InviteCardsByCardIdAsync(
        InviteEventGroupCardsByCardIdRequest request,
        CancellationToken cancellationToken = default)
    {
        await _inviteByCardIdValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var groupId = ParseGroupId(request.Id);
        var entity = await _eventGroupRepository.GetByUserAndIdAsync(userId, groupId, cancellationToken)
            ?? throw new NotFoundException("EventGroup", request.Id);

        var invalidCardIds = await _eventGroupRepository.InviteCardsByCardIdsAsync(
            userId,
            groupId,
            request.CardIds,
            cancellationToken);
        var cardCount = await _eventGroupRepository.CountCardsInGroupAsync(
            entity.Id,
            cancellationToken);

        return EventGroupMapper.ToDto(entity, cardCount, invalidCardIds);
    }

    public async Task<IReadOnlyList<EventGroupInvitationDto>> GetPendingInvitationsAsync(
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var invitations = await _eventGroupRepository.GetPendingInvitationsForInviteeAsync(
            userId,
            cancellationToken);

        return invitations
            .Select(EventGroupInvitationMapper.ToDto)
            .ToList();
    }

    public async Task AcceptInvitationAsync(
        RespondEventGroupInvitationRequest request,
        CancellationToken cancellationToken = default)
    {
        await _respondInvitationValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var invitationId = ParseInvitationId(request.Id);
        var invitation = await _eventGroupRepository.GetInvitationForInviteeAsync(
            userId,
            invitationId,
            cancellationToken)
            ?? throw new NotFoundException("EventGroupInvitation", request.Id);

        if (invitation.Status != EventGroupInvitationStatuses.Pending)
        {
            throw new ConflictException(
                "Invitation is no longer pending.",
                ErrorCodes.EventGroupInvitationNotPending);
        }

        if (EventGroupInvitationPolicy.IsExpired(invitation.ExpiresAtUtc))
        {
            throw new NotFoundException("EventGroupInvitation", request.Id);
        }

        await _eventGroupRepository.AcceptInvitationAsync(invitation, cancellationToken);
    }

    public async Task RejectInvitationAsync(
        RespondEventGroupInvitationRequest request,
        CancellationToken cancellationToken = default)
    {
        await _respondInvitationValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var invitationId = ParseInvitationId(request.Id);
        var invitation = await _eventGroupRepository.GetInvitationForInviteeAsync(
            userId,
            invitationId,
            cancellationToken)
            ?? throw new NotFoundException("EventGroupInvitation", request.Id);

        if (invitation.Status != EventGroupInvitationStatuses.Pending)
        {
            throw new ConflictException(
                "Invitation is no longer pending.",
                ErrorCodes.EventGroupInvitationNotPending);
        }

        if (EventGroupInvitationPolicy.IsExpired(invitation.ExpiresAtUtc))
        {
            throw new NotFoundException("EventGroupInvitation", request.Id);
        }

        await _eventGroupRepository.RejectInvitationAsync(invitation, cancellationToken);
    }

    private async Task ApplyPhotoAsync(
        EventGroup entity,
        Guid userId,
        Stream photoStream,
        string? contentType,
        long contentLength,
        CancellationToken cancellationToken)
    {
        ValidatePhotoUpload(contentType, contentLength);

        var photoUrl = await _eventGroupPhotoStorage.SaveEventGroupPhotoAsync(
            userId,
            entity.Id,
            photoStream,
            contentType!,
            cancellationToken);

        entity.PhotoUrl = photoUrl;
        await _eventGroupRepository.UpdateAsync(entity, cancellationToken);
    }

    private static void ValidatePhotoUpload(string? contentType, long contentLength)
    {
        if (contentLength <= 0 || contentLength > 5 * 1024 * 1024)
        {
            throw new ValidationException("Event photo must be at most 5 MB.");
        }

        if (string.IsNullOrWhiteSpace(contentType) ||
            !AllowedPhotoContentTypes.Contains(contentType))
        {
            throw new ValidationException(
                "Only JPEG, PNG, or WebP images are supported for event photos.");
        }
    }

    private async Task EnsureUniqueNameAsync(
        Guid userId,
        string name,
        Guid? excludeGroupId,
        CancellationToken cancellationToken)
    {
        var duplicate = await _eventGroupRepository.GetByUserAndNameAsync(userId, name, cancellationToken);
        if (duplicate is null)
        {
            return;
        }

        if (excludeGroupId.HasValue && duplicate.Id == excludeGroupId.Value)
        {
            return;
        }

        throw new ConflictException(
            "An event group with this name already exists.",
            ErrorCodes.DuplicateEventGroupName);
    }

    private async Task EnsureCanCreateEventGroupAsync(
        Guid userId,
        CancellationToken cancellationToken)
    {
        var entitlement = await _walletRepository.GetOrCreateAsync(userId, cancellationToken);
        if (WalletConstants.HasUnlimitedEventGroups(entitlement.Tier))
        {
            return;
        }

        var eventGroupCount = await _eventGroupRepository.CountByUserIdAsync(
            userId,
            cancellationToken);
        if (eventGroupCount >= WalletConstants.FreeMaxEventGroups)
        {
            throw new ForbiddenException(
                "Event group limit reached.",
                ErrorCodes.PlanLimitReached);
        }
    }

    private static string? NormalizeOptionalText(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            return null;
        }

        return value.Trim();
    }

    private static DateTime? NormalizeEventDate(DateTime? value)
    {
        if (!value.HasValue)
        {
            return null;
        }

        var date = value.Value;
        if (date.Kind == DateTimeKind.Unspecified)
        {
            date = DateTime.SpecifyKind(date, DateTimeKind.Utc);
        }

        return date.Kind == DateTimeKind.Utc
            ? date
            : date.ToUniversalTime();
    }

    private static DateTime NormalizeStartAt(DateTime? startAt, DateTime? legacyEventDate)
    {
        var normalized = NormalizeEventDate(startAt ?? legacyEventDate);
        if (normalized is null)
        {
            throw new ValidationException("Etkinlik başlangıç tarihi ve saati gereklidir.");
        }

        return normalized.Value;
    }

    private static Guid ParseGroupId(string groupId)
    {
        if (!Guid.TryParse(groupId, out var parsed))
        {
            throw new ValidationException("Invalid event group id.");
        }

        return parsed;
    }

    private static Guid ParseInvitationId(string invitationId)
    {
        if (!Guid.TryParse(invitationId, out var parsed))
        {
            throw new ValidationException("Invalid invitation id.");
        }

        return parsed;
    }
}
