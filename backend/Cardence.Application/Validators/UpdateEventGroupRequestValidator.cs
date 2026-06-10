using Cardence.Application.DTOs.EventGroups;
using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class UpdateEventGroupRequestValidator : AbstractValidator<UpdateEventGroupRequest>
{
    public UpdateEventGroupRequestValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty();

        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(200);
    }
}
