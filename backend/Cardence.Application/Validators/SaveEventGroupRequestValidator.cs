using Cardence.Application.DTOs.EventGroups;
using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class SaveEventGroupRequestValidator : AbstractValidator<SaveEventGroupRequest>
{
    public SaveEventGroupRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(200);
    }
}
