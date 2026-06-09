using Cardence.Application.DTOs.Support;
using Cardence.Application.Validation;
using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class SubmitSupportRequestValidator : AbstractValidator<SubmitSupportRequest>
{
    private static readonly HashSet<string> AllowedTopics = new(StringComparer.OrdinalIgnoreCase)
    {
        "general",
        "bug",
        "feature",
        "account",
        "wallet",
    };

    public SubmitSupportRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .MaximumLength(320)
            .Matches(ValidationPatterns.Email);

        RuleFor(x => x.Topic)
            .NotEmpty()
            .Must(topic => AllowedTopics.Contains(topic.Trim()))
            .WithMessage("Topic must be one of: general, bug, feature, account, wallet.");

        RuleFor(x => x.Message)
            .NotEmpty()
            .MinimumLength(10)
            .MaximumLength(2000);
    }
}
