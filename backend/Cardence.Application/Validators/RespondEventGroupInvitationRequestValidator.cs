using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class RespondEventGroupInvitationRequestValidator
    : AbstractValidator<DTOs.EventGroups.RespondEventGroupInvitationRequest>
{
    public RespondEventGroupInvitationRequestValidator()
    {
        RuleFor(request => request.Id)
            .NotEmpty()
            .Must(id => Guid.TryParse(id, out _))
            .WithMessage("Invalid invitation id.");
    }
}
