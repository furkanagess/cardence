using Cardence.Application.Common;
using Cardence.Application.DTOs.Cards;
using Cardence.Application.Interfaces;
using Cardence.Application.Mapping;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentValidation;
using FluentValidation.Results;

namespace Cardence.Application.Services;

public sealed class BusinessCardService : IBusinessCardService
{
    private readonly IBusinessCardRepository _repository;
    private readonly IUserRepository _userRepository;
    private readonly IEventGroupRepository _eventGroupRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IValidator<BusinessCardDto> _validator;

    public BusinessCardService(
        IBusinessCardRepository repository,
        IUserRepository userRepository,
        IEventGroupRepository eventGroupRepository,
        ICurrentUserService currentUser,
        IValidator<BusinessCardDto> validator)
    {
        _repository = repository;
        _userRepository = userRepository;
        _eventGroupRepository = eventGroupRepository;
        _currentUser = currentUser;
        _validator = validator;
    }

    public async Task<IReadOnlyList<BusinessCardDto>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var cards = await _repository.GetByUserIdAsync(userId, cancellationToken);
        return cards.Select(BusinessCardMapper.ToDto).ToList();
    }

    public async Task<BusinessCardDto> GetByCardIdAsync(string cardId, CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var card = await _repository.GetByUserAndCardIdAsync(userId, cardId, cancellationToken)
            ?? throw new NotFoundException("BusinessCard", cardId);

        return BusinessCardMapper.ToDto(card);
    }

    public async Task<BusinessCardDto> CreateAsync(BusinessCardDto request, CancellationToken cancellationToken = default)
    {
        await _validator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var cardId = string.IsNullOrWhiteSpace(request.CardId)
            ? await CardIdGenerator.GenerateUniqueAsync(
                (id, ct) => _repository.CardIdExistsAsync(id, cancellationToken: ct),
                cancellationToken)
            : request.CardId.Trim();

        if (await _repository.CardIdExistsAsync(cardId, cancellationToken: cancellationToken))
        {
            throw new ConflictException($"Card id '{cardId}' is already in use.", ErrorCodes.DuplicateCardId);
        }

        var now = DateTime.UtcNow;
        var entity = new BusinessCard
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CardId = cardId,
            CreatedAt = now,
            UpdatedAt = now,
        };

        BusinessCardMapper.ApplyDto(entity, request);
        await ApplyProfilePhotoFallbackAsync(entity, userId, cancellationToken);
        await _repository.AddAsync(entity, cancellationToken);

        return BusinessCardMapper.ToDto(entity);
    }

    public async Task<BusinessCardDto> UpsertAsync(
        string cardId,
        BusinessCardDto request,
        CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrWhiteSpace(request.CardId) &&
            !string.Equals(request.CardId, cardId, StringComparison.Ordinal))
        {
            throw new ValidationException([
                new ValidationFailure("cardId", "Request cardId values do not match."),
            ]);
        }

        await _validator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var existing = await _repository.GetByUserAndCardIdAsync(userId, cardId, cancellationToken);

        if (existing is null)
        {
            var createRequest = new BusinessCardDto
            {
                CardName = request.CardName,
                DisplayName = request.DisplayName,
                Email = request.Email,
                Phone = request.Phone,
                Company = request.Company,
                Title = request.Title,
                Website = request.Website,
                Linkedin = request.Linkedin,
                Skills = request.Skills,
                School = request.School,
                About = request.About,
                PhotoUrl = request.PhotoUrl,
                AccentColor = request.AccentColor,
                BackgroundColor = request.BackgroundColor,
                LastUsedPaletteBackgroundColor = request.LastUsedPaletteBackgroundColor,
                CardId = cardId,
            };
            return await CreateAsync(createRequest, cancellationToken);
        }

        BusinessCardMapper.ApplyDto(existing, request);
        await ApplyProfilePhotoFallbackAsync(existing, userId, cancellationToken);
        await _repository.UpdateAsync(existing, cancellationToken);

        return BusinessCardMapper.ToDto(existing);
    }

    public async Task DeleteAsync(string cardId, CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var card = await _repository.GetByUserAndCardIdAsync(userId, cardId, cancellationToken)
            ?? throw new NotFoundException("BusinessCard", cardId);

        await _repository.DeleteAsync(card, cancellationToken);
    }

    public async Task<IReadOnlyDictionary<string, object?>> GetSharePayloadAsync(
        string cardId,
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var card = await _repository.GetByUserAndCardIdAsync(userId, cardId, cancellationToken)
            ?? throw new NotFoundException("BusinessCard", cardId);

        return BusinessCardMapper.ToSharePayload(card);
    }

    public async Task<IReadOnlyDictionary<string, object?>> GetPublicSharePayloadAsync(
        string cardId,
        CancellationToken cancellationToken = default)
    {
        var card = await _repository.GetByCardIdAsync(cardId, cancellationToken)
            ?? throw new NotFoundException("BusinessCard", cardId);

        return BusinessCardMapper.ToSharePayload(card);
    }

    public async Task<bool> PublicCardExistsAsync(string cardId, CancellationToken cancellationToken = default)
    {
        return await _repository.GetByCardIdAsync(cardId, cancellationToken) is not null;
    }

    public async Task<ProfileStatsDto> GetProfileStatsAsync(
        CancellationToken cancellationToken = default)
    {
        var userId = _currentUser.GetRequiredUserId();
        var totalWalletSaveCount = await _repository.SumSaveCountByUserIdAsync(
            userId,
            cancellationToken);
        var groups = await _eventGroupRepository.GetByUserIdAsync(userId, cancellationToken);

        return new ProfileStatsDto
        {
            TotalWalletSaveCount = totalWalletSaveCount,
            EventGroupCount = groups.Count,
        };
    }

    private async Task ApplyProfilePhotoFallbackAsync(
        BusinessCard entity,
        Guid userId,
        CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(entity.PhotoUrl))
        {
            return;
        }

        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (!string.IsNullOrWhiteSpace(user?.PhotoUrl))
        {
            entity.PhotoUrl = user!.PhotoUrl;
        }
    }
}
