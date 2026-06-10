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

namespace Cardence.Application.Services;

public sealed class SavedCardService : ISavedCardService
{
    private readonly ISavedCardRepository _savedCardRepository;
    private readonly IBusinessCardRepository _businessCardRepository;
    private readonly IWalletEntitlementRepository _walletRepository;
    private readonly IEventGroupRepository _eventGroupRepository;
    private readonly ICurrentUserService _currentUser;

    public SavedCardService(
        ISavedCardRepository savedCardRepository,
        IBusinessCardRepository businessCardRepository,
        IWalletEntitlementRepository walletRepository,
        IEventGroupRepository eventGroupRepository,
        ICurrentUserService currentUser)
    {
        _savedCardRepository = savedCardRepository;
        _businessCardRepository = businessCardRepository;
        _walletRepository = walletRepository;
        _eventGroupRepository = eventGroupRepository;
        _currentUser = currentUser;
    }

    public async Task<IReadOnlyList<SavedCardDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var cards = await _savedCardRepository.GetByUserIdAsync(userId, cancellationToken);
        return cards.Select(SavedCardMapper.ToDto).ToList();
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

        SavedCardMapper.ApplyDto(existing, request);
        await _savedCardRepository.UpdateAsync(existing, cancellationToken);
        await _eventGroupRepository.SyncSavedCardLinksAsync(
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
        var maxCards = entitlement.MaxCards;
        var remaining = Math.Max(0, maxCards - usedCount);
        var usageFraction = maxCards == 0 ? 0 : Math.Clamp((double)usedCount / maxCards, 0, 1);

        return new WalletQuotaDto
        {
            Tier = entitlement.Tier,
            UsedCount = usedCount,
            MaxCards = maxCards,
            Remaining = remaining,
            CanAddMore = usedCount < maxCards,
            IsNearLimit = maxCards > 0 && usedCount >= (int)Math.Ceiling(maxCards * 0.85),
            UsageFraction = usageFraction,
        };
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

        var entitlement = await _walletRepository.GetOrCreateAsync(userId, cancellationToken);
        var usedCount = await _savedCardRepository.CountByUserIdAsync(userId, cancellationToken);
        if (usedCount >= entitlement.MaxCards)
        {
            throw new ForbiddenException(
                "Wallet card limit reached.",
                ErrorCodes.WalletLimitReached);
        }

        var businessCard = await _businessCardRepository.GetByCardIdAsync(cardId, cancellationToken);
        if (businessCard is null && IsStubRequest(request))
        {
            throw new ValidationException([
                new ValidationFailure(
                    "cardId",
                    "Card not found. Check the ID or scan the QR code."),
            ]);
        }

        var entity = new SavedCard
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CardId = cardId,
            SavedAt = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds(),
            SortOrder = usedCount,
            LinkedEventGroupIds = request.LinkedEventGroupIds.ToList(),
        };

        SavedCardMapper.ApplyDto(entity, request);

        if (businessCard is not null)
        {
            SavedCardMapper.HydrateFromBusinessCard(entity, businessCard);
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

        await _savedCardRepository.AddAsync(entity, cancellationToken);
        await _eventGroupRepository.SyncSavedCardLinksAsync(
            userId,
            entity.Id,
            request.LinkedEventGroupIds,
            cancellationToken);
        entity.LinkedEventGroupIds = request.LinkedEventGroupIds.ToList();

        return SavedCardMapper.ToDto(entity);
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
}
