using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class RespondWalletCardInvitationRequestValidator
    : AbstractValidator<DTOs.Wallet.RespondWalletCardInvitationRequest>
{
    public RespondWalletCardInvitationRequestValidator()
    {
        RuleFor(request => request.Id)
            .NotEmpty()
            .Must(id => Guid.TryParse(id, out _))
            .WithMessage("Invalid invitation id.");
    }
}
