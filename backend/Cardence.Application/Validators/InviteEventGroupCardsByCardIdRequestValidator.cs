using Cardence.Application.DTOs.EventGroups;
using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class InviteEventGroupCardsByCardIdRequestValidator
    : AbstractValidator<InviteEventGroupCardsByCardIdRequest>
{
    public InviteEventGroupCardsByCardIdRequestValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty()
            .WithMessage("Etkinlik kimliği gereklidir.");

        RuleFor(x => x.CardIds)
            .NotEmpty()
            .WithMessage("En az bir Card ID girilmelidir.");

        RuleFor(x => x.CardIds)
            .Must(ids => ids.Count <= 50)
            .WithMessage("Tek seferde en fazla 50 kart davet edilebilir.");

        RuleForEach(x => x.CardIds)
            .MaximumLength(64)
            .Must(cardId => !string.IsNullOrWhiteSpace(cardId))
            .WithMessage("Card ID boş olamaz.");
    }
}
