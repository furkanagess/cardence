using System.Text.Json;
using Cardence.Application.Common;
using Cardence.Application.DTOs.Wallet;
using Cardence.Application.Interfaces;
using Cardence.Application.Mapping;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.Extensions.Logging;

namespace Cardence.Application.Services;

public sealed class SavedCardService : ISavedCardService
{
    private readonly ISavedCardRepository _savedCardRepository;
    private readonly IBusinessCardRepository _businessCardRepository;
    private readonly IWalletEntitlementRepository _walletRepository;
    private readonly IEventGroupRepository _eventGroupRepository;
    private readonly IWalletCardInviteRepository _walletCardInviteRepository;
    private readonly IWalletOwnerPremiumSyncService _ownerPremiumSync;
    private readonly IWalletEntitlementSyncService _walletEntitlementSync;
    private readonly ICurrentUserService _currentUser;
    private readonly IPushNotificationService _pushNotificationService;
    private readonly IUserRepository _userRepository;
    private readonly IValidator<RespondWalletCardInvitationRequest> _respondInvitationValidator;
    private readonly ILogger<SavedCardService> _logger;

    public SavedCardService(
        ISavedCardRepository savedCardRepository,
        IBusinessCardRepository businessCardRepository,
        IWalletEntitlementRepository walletRepository,
        IEventGroupRepository eventGroupRepository,
        IWalletCardInviteRepository walletCardInviteRepository,
        IWalletOwnerPremiumSyncService ownerPremiumSync,
        IWalletEntitlementSyncService walletEntitlementSync,
        ICurrentUserService currentUser,
        IPushNotificationService pushNotificationService,
        IUserRepository userRepository,
        IValidator<RespondWalletCardInvitationRequest> respondInvitationValidator,
        ILogger<SavedCardService> logger)
    {
        _savedCardRepository = savedCardRepository;
        _businessCardRepository = businessCardRepository;
        _walletRepository = walletRepository;
        _eventGroupRepository = eventGroupRepository;
        _walletCardInviteRepository = walletCardInviteRepository;
        _ownerPremiumSync = ownerPremiumSync;
        _walletEntitlementSync = walletEntitlementSync;
        _currentUser = currentUser;
        _pushNotificationService = pushNotificationService;
        _userRepository = userRepository;
        _respondInvitationValidator = respondInvitationValidator;
        _logger = logger;
    }

    public async Task<IReadOnlyList<SavedCardDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var cards = await _savedCardRepository.GetByUserIdAsync(userId, cancellationToken);
        await SavedCardEnrichment.HydrateLinkedProfilesAsync(
            cards,
            _businessCardRepository,
            cancellationToken);
        return SavedCardEnrichment
            .SortForWalletDisplay(cards)
            .Select(SavedCardMapper.ToDto)
            .ToList();
    }

    public async Task<SavedCardDto> CreateFromJsonAsync(
        JsonElement body,
        CancellationToken cancellationToken = default)
    {
        var request = ParseRequest(body);
        return await CreateAsync(request, cancellationToken);
    }

    public async Task<SavedCardDto> UpdateAsync(
        SavedCardDto request,
        CancellationToken cancellationToken = default)
    {
        ValidateCardId(request.CardId);

        var userId = _currentUser.GetRequiredUserId();
        var existing = await _savedCardRepository.GetByUserAndCardIdAsync(
            userId,
            request.CardId.Trim(),
            cancellationToken)
            ?? throw new NotFoundException("SavedCard", request.CardId);

        existing.Note = request.Note;
        existing.LinkedEventGroupIds = request.LinkedEventGroupIds.ToList();

        if (CardCreationMethods.IsManualEntry(existing.CreationMethod))
        {
            SavedCardMapper.ApplyManualProfile(existing, request);
        }
        else
        {
            SavedCardMapper.ApplyExtendedProfile(existing, request);
        }

        await _savedCardRepository.UpdateAsync(existing, cancellationToken);
        await _eventGroupRepository.SyncWalletCardLinksAsync(
            userId,
            existing.Id,
            request.LinkedEventGroupIds,
            cancellationToken);
        existing.LinkedEventGroupIds = request.LinkedEventGroupIds.ToList();

        return SavedCardMapper.ToDto(existing);
    }

    public async Task DeleteAsync(string cardId, CancellationToken cancellationToken = default)
    {
        ValidateCardId(cardId);

        var userId = _currentUser.GetRequiredUserId();
        var existing = await _savedCardRepository.GetByUserAndCardIdAsync(
            userId,
            cardId.Trim(),
            cancellationToken)
            ?? throw new NotFoundException("SavedCard", cardId);

        await _savedCardRepository.DeleteAsync(existing, cancellationToken);
    }

    public async Task<WalletQuotaDto> GetWalletQuotaAsync(CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var entitlement = await _walletRepository.GetOrCreateAsync(userId, cancellationToken);
        var usedCount = await _savedCardRepository.CountByUserIdAsync(userId, cancellationToken);
        var businessCardCount = await _businessCardRepository.CountByUserIdAsync(
            userId,
            cancellationToken);
        var canAddManualSavedCard = true;
        var eventGroupCount = await _eventGroupRepository.CountByUserIdAsync(
            userId,
            cancellationToken);
        var unlimitedEventGroups = WalletConstants.HasUnlimitedEventGroups(entitlement.Tier);
        var unlimitedWallet = WalletConstants.HasUnlimitedWalletCards(entitlement.Tier);
        var maxCards = unlimitedWallet
            ? WalletConstants.PremiumMaxCards
            : entitlement.MaxCards;
        var maxBusinessCards = WalletConstants.GetMaxBusinessCards(entitlement.Tier);
        var displayedMaxBusinessCards =
            maxBusinessCards ?? WalletConstants.PremiumMaxBusinessCards;
        var canAddBusinessCard = maxBusinessCards is null ||
            businessCardCount < displayedMaxBusinessCards;
        var remaining = unlimitedWallet
            ? 0
            : Math.Max(0, entitlement.MaxCards - usedCount);
        var usageFraction = unlimitedWallet || entitlement.MaxCards <= 0
            ? 0
            : Math.Clamp((double)usedCount / entitlement.MaxCards, 0, 1);

        return new WalletQuotaDto
        {
            Tier = entitlement.Tier,
            UsedCount = usedCount,
            MaxCards = maxCards,
            Remaining = remaining,
            CanAddMore = unlimitedWallet || usedCount < entitlement.MaxCards,
            IsNearLimit = !unlimitedWallet &&
                entitlement.MaxCards > 0 &&
                usedCount >= (int)Math.Ceiling(entitlement.MaxCards * 0.85),
            UsageFraction = usageFraction,
            BusinessCardCount = businessCardCount,
            MaxBusinessCards = displayedMaxBusinessCards,
            CanAddBusinessCard = canAddBusinessCard,
            CanAddManualSavedCard = canAddManualSavedCard,
            EventGroupCount = eventGroupCount,
            MaxEventGroups = unlimitedEventGroups
                ? 0
                : WalletConstants.FreeMaxEventGroups,
            CanAddEventGroup = unlimitedEventGroups ||
                eventGroupCount < WalletConstants.FreeMaxEventGroups,
        };
    }

    public async Task<WalletQuotaDto> UpgradeWalletPlanAsync(
        CancellationToken cancellationToken = default)
    {
        // RevenueCat satın alması / iptali sonrası istemci bu uç noktayı çağırır.
        var userId = _currentUser.GetRequiredUserId();
        await _walletEntitlementSync.SyncUserAfterClientPurchaseAsync(
            userId,
            cancellationToken);
        return await GetWalletQuotaAsync(cancellationToken);
    }

    private async Task<SavedCardDto> CreateAsync(
        SavedCardDto request,
        CancellationToken cancellationToken)
    {
        ValidateCardId(request.CardId);

        var userId = _currentUser.GetRequiredUserId();
        var cardId = request.CardId.Trim();

        var duplicate = await _savedCardRepository.GetByUserAndCardIdAsync(
            userId,
            cardId,
            cancellationToken);
        if (duplicate is not null)
        {
            throw new ConflictException(
                "This card is already in your wallet.",
                ErrorCodes.WalletDuplicateCard);
        }

        var usedCount = await _savedCardRepository.CountByUserIdAsync(userId, cancellationToken);

        var creationMethod = CardCreationMethods.NormalizeWallet(
            request.CreationMethod,
            request.SourceType,
            cardId,
            fromQrPayload: false);
        var isManual = CardCreationMethods.IsManualEntry(creationMethod);

        if (isManual && !CardIdGenerator.IsManualWalletId(cardId))
        {
            throw new ValidationException([
                new ValidationFailure(
                    "cardId",
                    "Manual wallet cards must use a 900000–999999 id."),
            ]);
        }

        if (!isManual && CardIdGenerator.IsManualWalletId(cardId))
        {
            throw new ValidationException([
                new ValidationFailure(
                    "cardId",
                    "This id is reserved for manual wallet entries."),
            ]);
        }

        var ownCard = isManual
            ? null
            : await _businessCardRepository.GetByCardIdAsync(cardId, cancellationToken);

        if (ownCard is not null && ownCard.UserId == userId)
        {
            throw new ConflictException(
                "You cannot add your own card to saved cards.",
                ErrorCodes.WalletOwnCardForbidden);
        }

        if (!isManual && ownCard is null && IsStubRequest(request))
        {
            throw new ValidationException([
                new ValidationFailure(
                    "cardId",
                    "Card not found. Check the ID or scan the QR code."),
            ]);
        }

        var now = DateTime.UtcNow;
        var entity = new SavedCard
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CardId = cardId,
            CreationMethod = creationMethod,
            SavedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            SortOrder = usedCount,
            CreatedAt = now,
            UpdatedAt = now,
            LinkedEventGroupIds = request.LinkedEventGroupIds.ToList(),
        };

        SavedCardMapper.ApplyDto(entity, request);
        entity.CreationMethod = creationMethod;

        if (ownCard is not null)
        {
            var note = entity.Note;
            SavedCardMapper.HydrateFromOwnCard(entity, ownCard);
            entity.Note = note;
            entity.IsOwnerPremium = ownCard.IsOwnerPremium;
        }

        if (string.IsNullOrWhiteSpace(entity.DisplayName) &&
            string.IsNullOrWhiteSpace(entity.Email) &&
            string.IsNullOrWhiteSpace(entity.Phone))
        {
            throw new ValidationException([
                new ValidationFailure(
                    "cardId",
                    "Invalid card payload."),
            ]);
        }

        await EnsureCanAddToWalletAsync(userId, cancellationToken);

        await _savedCardRepository.AddAsync(entity, cancellationToken);
        if (ownCard is not null && ownCard.UserId != userId)
        {
            await _businessCardRepository.IncrementSaveCountAsync(
                ownCard.Id,
                cancellationToken);

            await NotifyCardOwnerAsync(
                ownCard.UserId,
                cardId,
                userId,
                cancellationToken);

            await TryCreateReciprocalInviteAsync(
                inviteeUserId: ownCard.UserId,
                inviterUserId: userId,
                savedCardId: cardId,
                cancellationToken);
        }
        await _eventGroupRepository.SyncWalletCardLinksAsync(
            userId,
            entity.Id,
            request.LinkedEventGroupIds,
            cancellationToken);
        entity.LinkedEventGroupIds = request.LinkedEventGroupIds.ToList();

        return SavedCardMapper.ToDto(entity);
    }

    public async Task<IReadOnlyList<WalletCardInvitationDto>> GetPendingInvitationsAsync(
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var invitations = await _walletCardInviteRepository.GetPendingForInviteeAsync(
            userId,
            cancellationToken);

        return invitations
            .Select(WalletCardInvitationMapper.ToDto)
            .ToList();
    }

    public async Task AcceptInvitationAsync(
        RespondWalletCardInvitationRequest request,
        CancellationToken cancellationToken = default)
    {
        await _respondInvitationValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var invitation = await GetPendingInvitationOrThrowAsync(
            userId,
            request.Id,
            cancellationToken);

        await EnsureCanAddToWalletAsync(userId, cancellationToken);

        var proposedCard = invitation.ProposedCard
            ?? await _businessCardRepository.GetByCardIdAsync(
                invitation.ProposedCardId,
                cancellationToken)
            ?? throw new NotFoundException("Card", invitation.ProposedCardId);

        var existing = await _savedCardRepository.GetByUserAndCardIdAsync(
            userId,
            proposedCard.CardId,
            cancellationToken);

        if (existing is null)
        {
            var usedCount = await _savedCardRepository.CountByUserIdAsync(
                userId,
                cancellationToken);
            var now = DateTime.UtcNow;
            var entity = CreateSavedCardFromBusinessCard(
                userId,
                proposedCard,
                usedCount,
                now);

            await _savedCardRepository.AddAsync(entity, cancellationToken);
            await _businessCardRepository.IncrementSaveCountAsync(
                proposedCard.Id,
                cancellationToken);
        }

        invitation.Status = EventGroupInvitationStatuses.Accepted;
        invitation.RespondedAtUtc = DateTime.UtcNow;
        await _walletCardInviteRepository.SaveChangesAsync(cancellationToken);
    }

    public async Task RejectInvitationAsync(
        RespondWalletCardInvitationRequest request,
        CancellationToken cancellationToken = default)
    {
        await _respondInvitationValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var invitation = await GetPendingInvitationOrThrowAsync(
            userId,
            request.Id,
            cancellationToken);

        invitation.Status = EventGroupInvitationStatuses.Rejected;
        invitation.RespondedAtUtc = DateTime.UtcNow;
        await _walletCardInviteRepository.SaveChangesAsync(cancellationToken);
    }

    private async Task<WalletCardInvite> GetPendingInvitationOrThrowAsync(
        Guid inviteeUserId,
        string invitationIdRaw,
        CancellationToken cancellationToken)
    {
        if (!Guid.TryParse(invitationIdRaw, out var invitationId))
        {
            throw new NotFoundException("WalletCardInvitation", invitationIdRaw);
        }

        var invitation = await _walletCardInviteRepository.GetForInviteeAsync(
            inviteeUserId,
            invitationId,
            cancellationToken)
            ?? throw new NotFoundException("WalletCardInvitation", invitationIdRaw);

        if (invitation.Status != EventGroupInvitationStatuses.Pending)
        {
            throw new ConflictException(
                "Invitation is no longer pending.",
                ErrorCodes.WalletCardInvitationNotPending);
        }

        if (EventGroupInvitationPolicy.IsExpired(invitation.ExpiresAtUtc))
        {
            throw new NotFoundException("WalletCardInvitation", invitationIdRaw);
        }

        return invitation;
    }

    private async Task EnsureCanAddToWalletAsync(
        Guid userId,
        CancellationToken cancellationToken)
    {
        var entitlement = await _walletRepository.GetOrCreateAsync(userId, cancellationToken);
        if (WalletConstants.HasUnlimitedWalletCards(entitlement.Tier))
        {
            return;
        }

        var usedCount = await _savedCardRepository.CountByUserIdAsync(userId, cancellationToken);
        if (usedCount >= entitlement.MaxCards)
        {
            throw new ForbiddenException(
                "Wallet card limit reached.",
                ErrorCodes.WalletLimitReached);
        }
    }

    private async Task TryCreateReciprocalInviteAsync(
        Guid inviteeUserId,
        Guid inviterUserId,
        string savedCardId,
        CancellationToken cancellationToken)
    {
        if (inviteeUserId == inviterUserId)
        {
            return;
        }

        try
        {
            var inviterCards = await _businessCardRepository.GetByUserIdAsync(
                inviterUserId,
                cancellationToken);
            // En güncel kendi kart (QR / link ile karşılıklı ekleme için)
            var proposedCard = inviterCards.FirstOrDefault();
            if (proposedCard is null)
            {
                _logger.LogDebug(
                    "Reciprocal wallet invite skipped: inviter {InviterUserId} has no business card.",
                    inviterUserId);
                return;
            }

            var alreadySaved = await _savedCardRepository.GetByUserAndCardIdAsync(
                inviteeUserId,
                proposedCard.CardId,
                cancellationToken);
            if (alreadySaved is not null)
            {
                _logger.LogDebug(
                    "Reciprocal wallet invite skipped: invitee {InviteeUserId} already has card {CardId}.",
                    inviteeUserId,
                    proposedCard.CardId);
                return;
            }

            var now = DateTime.UtcNow;
            await _walletCardInviteRepository.UpsertPendingAsync(
                new WalletCardInvite
                {
                    Id = Guid.NewGuid(),
                    InviterUserId = inviterUserId,
                    InviteeUserId = inviteeUserId,
                    ProposedCardEntityId = proposedCard.Id,
                    ProposedCardId = proposedCard.CardId,
                    SavedCardId = savedCardId,
                    Status = EventGroupInvitationStatuses.Pending,
                    CreatedAtUtc = now,
                    ExpiresAtUtc = EventGroupInvitationPolicy.ComputeExpiresAtUtc(now),
                },
                cancellationToken);

            _logger.LogInformation(
                "Reciprocal wallet invite created: invitee={InviteeUserId}, inviter={InviterUserId}, proposedCard={ProposedCardId}",
                inviteeUserId,
                inviterUserId,
                proposedCard.CardId);
        }
        catch (Exception ex)
        {
            // Davet oluşturma başarısız olsa da kaydetme akışı tamamlanmış sayılır.
            _logger.LogWarning(
                ex,
                "Failed to create reciprocal wallet invite for invitee {InviteeUserId} from inviter {InviterUserId}.",
                inviteeUserId,
                inviterUserId);
        }
    }

    private static SavedCard CreateSavedCardFromBusinessCard(
        Guid userId,
        Card card,
        int sortOrder,
        DateTime now)
    {
        return new SavedCard
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CardId = card.CardId,
            CreationMethod = CardCreationMethods.CardenceLink,
            DisplayName = card.DisplayName,
            Email = card.Email,
            Phone = card.Phone,
            Company = card.Company,
            Title = card.Title,
            Website = card.Website,
            Linkedin = card.Linkedin,
            Skills = card.Skills,
            School = card.School,
            About = card.About,
            Address = card.Address,
            City = card.City,
            Country = card.Country,
            Department = card.Department,
            AttendedEvents = card.AttendedEvents,
            Twitter = card.Twitter,
            Instagram = card.Instagram,
            Birthday = card.Birthday,
            PhotoUrl = card.PhotoUrl,
            AccentColor = card.AccentColor,
            BackgroundColor = card.BackgroundColor,
            SavedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            SortOrder = sortOrder,
            IsOwnerPremium = card.IsOwnerPremium,
            CreatedAt = now,
            UpdatedAt = now,
        };
    }

    private static bool IsStubRequest(SavedCardDto request)
    {
        return string.IsNullOrWhiteSpace(request.DisplayName) &&
               string.IsNullOrWhiteSpace(request.Email) &&
               string.IsNullOrWhiteSpace(request.Phone) &&
               string.IsNullOrWhiteSpace(request.Company) &&
               string.IsNullOrWhiteSpace(request.Title) &&
               string.IsNullOrWhiteSpace(request.Website) &&
               string.IsNullOrWhiteSpace(request.Linkedin) &&
               string.IsNullOrWhiteSpace(request.Skills) &&
               string.IsNullOrWhiteSpace(request.School);
    }

    private static SavedCardDto ParseRequest(JsonElement body)
    {
        if (body.ValueKind != JsonValueKind.Object)
        {
            throw new ValidationException([
                new ValidationFailure("body", "Request body must be a JSON object."),
            ]);
        }

        if (TryGetString(body, "id", out var shareId) || TryGetString(body, "Id", out shareId))
        {
            return new SavedCardDto
            {
                CardId = shareId!,
                SourceType = SavedCardSourceType.Cardence,
                CreationMethod = CardCreationMethods.QrScan,
                DisplayName = ReadOptionalString(body, "n", "displayName", "DisplayName"),
                Email = ReadOptionalString(body, "e", "email", "Email"),
                Phone = ReadOptionalString(body, "p", "phone", "Phone"),
                Company = ReadOptionalString(body, "c", "company", "Company"),
                Title = ReadOptionalString(body, "t", "title", "Title"),
                Website = ReadOptionalString(body, "w", "website", "Website"),
                Linkedin = ReadOptionalString(body, "l", "linkedin", "Linkedin"),
                Skills = ReadOptionalString(body, "s", "skills", "Skills"),
                School = ReadOptionalString(body, "o", "school", "School"),
                About = ReadOptionalString(body, "h", "about", "About"),
                Address = ReadOptionalString(body, "a", "address", "Address"),
                City = ReadOptionalString(body, "ci", "city", "City"),
                Country = ReadOptionalString(body, "co", "country", "Country"),
                Department = ReadOptionalString(body, "d", "department", "Department"),
                AttendedEvents = ReadOptionalString(
                    body,
                    "ae",
                    "attendedEvents",
                    "AttendedEvents"),
                Twitter = ReadOptionalString(body, "tw", "twitter", "Twitter"),
                Instagram = ReadOptionalString(body, "ig", "instagram", "Instagram"),
                Birthday = ReadOptionalString(body, "bd", "birthday", "Birthday"),
                AccentColor = ReadOptionalString(body, "tc", "accentColor", "AccentColor"),
                BackgroundColor = ReadOptionalString(body, "bc", "backgroundColor", "BackgroundColor"),
                PhotoUrl = ReadOptionalString(body, "ph", "photoUrl", "PhotoUrl"),
            };
        }

        var dto = body.Deserialize<SavedCardDto>(JsonSerializerOptions.Web)
            ?? throw new ValidationException([
                new ValidationFailure("body", "Request body is invalid."),
            ]);

        return dto;
    }

    private static string? ReadOptionalString(JsonElement body, params string[] keys)
    {
        foreach (var key in keys)
        {
            if (TryGetString(body, key, out var value))
            {
                return value;
            }
        }

        return null;
    }

    private static bool TryGetString(JsonElement body, string key, out string? value)
    {
        value = null;
        if (!body.TryGetProperty(key, out var property))
        {
            return false;
        }

        if (property.ValueKind != JsonValueKind.String)
        {
            return false;
        }

        var text = property.GetString()?.Trim();
        if (string.IsNullOrEmpty(text))
        {
            return false;
        }

        value = text;
        return true;
    }

    private static void ValidateCardId(string? cardId)
    {
        if (!CardIdGenerator.IsValid(cardId))
        {
            throw new ValidationException([
                new ValidationFailure(
                    "cardId",
                    "Card id must be exactly 6 digits."),
            ]);
        }
    }

    private async Task NotifyCardOwnerAsync(
        Guid cardOwnerUserId,
        string cardId,
        Guid saverUserId,
        CancellationToken cancellationToken)
    {
        try
        {
            var saver = await _userRepository.GetByIdAsync(saverUserId, cancellationToken);
            await _pushNotificationService.NotifyCardSavedAsync(
                cardOwnerUserId,
                cardId,
                saver?.DisplayName,
                cancellationToken);
        }
        catch (Exception)
        {
            // Push başarısız olsa da kaydetme akışı tamamlanmış sayılır.
        }
    }
}
