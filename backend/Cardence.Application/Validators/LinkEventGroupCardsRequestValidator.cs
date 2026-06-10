using Cardence.Application.Common;
using Cardence.Application.DTOs.EventGroups;
using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class LinkEventGroupCardsRequestValidator : AbstractValidator<LinkEventGroupCardsRequest>
{
    public LinkEventGroupCardsRequestValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty();

        RuleFor(x => x.CardIds)
            .NotNull();

        RuleForEach(x => x.CardIds)
            .Must(CardIdGenerator.IsValid)
            .WithMessage("Each card id must be exactly 6 digits.");
    }
}
