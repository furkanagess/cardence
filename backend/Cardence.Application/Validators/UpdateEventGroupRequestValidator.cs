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

        RuleFor(x => x.Location)
            .NotEmpty()
            .MaximumLength(500)
            .WithMessage("Etkinlik konumu gereklidir.");

        RuleFor(x => x.Description)
            .MaximumLength(2000)
            .When(x => !string.IsNullOrWhiteSpace(x.Description));

        RuleFor(x => x)
            .Must(x => x.StartAt.HasValue || x.EventDate.HasValue)
            .WithMessage("Etkinlik başlangıç tarihi ve saati gereklidir.");

        RuleFor(x => x)
            .Must(x => !x.EndAt.HasValue || (x.StartAt ?? x.EventDate).HasValue && x.EndAt.Value >= (x.StartAt ?? x.EventDate)!.Value)
            .WithMessage("Bitiş tarihi başlangıç tarihinden önce olamaz.");
    }
}
