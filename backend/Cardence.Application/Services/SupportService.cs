using Cardence.Application.DTOs.Support;
using Cardence.Application.Interfaces;
using Cardence.Domain.Entities;
using FluentValidation;

namespace Cardence.Application.Services;

public sealed class SupportService : ISupportService
{
    private readonly ISupportRequestRepository _repository;
    private readonly ICurrentUserService _currentUser;
    private readonly IValidator<SubmitSupportRequest> _validator;

    public SupportService(
        ISupportRequestRepository repository,
        ICurrentUserService currentUser,
        IValidator<SubmitSupportRequest> validator)
    {
        _repository = repository;
        _currentUser = currentUser;
        _validator = validator;
    }

    public async Task<SupportRequestDto> SubmitAsync(
        SubmitSupportRequest request,
        CancellationToken cancellationToken = default)
    {
        await _validator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var now = DateTime.UtcNow;
        var entity = new SupportRequest
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Email = request.Email.Trim(),
            Topic = request.Topic.Trim().ToLowerInvariant(),
            Message = request.Message.Trim(),
            CreatedAt = now,
        };

        await _repository.AddAsync(entity, cancellationToken);

        return new SupportRequestDto
        {
            RequestId = entity.Id,
            Email = entity.Email,
            Topic = entity.Topic,
            CreatedAt = entity.CreatedAt,
        };
    }
}
