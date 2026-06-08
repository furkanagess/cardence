using Cardence.Application.DTOs.Cards;
using Cardence.Application.Validation;
using Cardence.Domain.Constants;
using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class BusinessCardDtoValidator : AbstractValidator<BusinessCardDto>
{
    public BusinessCardDtoValidator()
    {
        RuleFor(x => x.CardId)
            .Matches(ValidationPatterns.CardId)
            .When(x => !string.IsNullOrWhiteSpace(x.CardId))
            .WithMessage("cardId must be at least 8 alphanumeric characters.");

        RuleFor(x => x.DisplayName)
            .Must(HasValidFullName)
            .When(x => !string.IsNullOrWhiteSpace(x.DisplayName))
            .WithMessage("displayName must contain first and last name.");

        RuleFor(x => x.Email)
            .Matches(ValidationPatterns.Email)
            .When(x => !string.IsNullOrWhiteSpace(x.Email))
            .WithMessage("email format is invalid.");

        RuleFor(x => x.Company)
            .Matches(ValidationPatterns.OrganizationText)
            .When(x => !string.IsNullOrWhiteSpace(x.Company))
            .WithMessage("company format is invalid.");

        RuleFor(x => x.Title)
            .Matches(ValidationPatterns.OrganizationText)
            .When(x => !string.IsNullOrWhiteSpace(x.Title))
            .WithMessage("title format is invalid.");

        RuleFor(x => x.About)
            .MaximumLength(BusinessCardConstants.MaxAboutLength)
            .When(x => !string.IsNullOrWhiteSpace(x.About));

        RuleFor(x => x.Skills)
            .Must(HasValidSkillTokens)
            .When(x => !string.IsNullOrWhiteSpace(x.Skills))
            .WithMessage("skills contain invalid tokens.");

        RuleFor(x => x.AccentColor)
            .Matches(ValidationPatterns.HexColor)
            .When(x => !string.IsNullOrWhiteSpace(x.AccentColor));

        RuleFor(x => x.BackgroundColor)
            .Matches(ValidationPatterns.HexColor)
            .When(x => !string.IsNullOrWhiteSpace(x.BackgroundColor));

        RuleFor(x => x.LastUsedPaletteBackgroundColor)
            .Matches(ValidationPatterns.HexColor)
            .When(x => !string.IsNullOrWhiteSpace(x.LastUsedPaletteBackgroundColor));
    }

    private static bool HasValidFullName(string? displayName)
    {
        if (string.IsNullOrWhiteSpace(displayName))
        {
            return false;
        }

        var parts = displayName.Trim().Split(' ', StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length < 2)
        {
            return false;
        }

        return parts.All(part => System.Text.RegularExpressions.Regex.IsMatch(part, ValidationPatterns.PersonName));
    }

    private static bool HasValidSkillTokens(string? skills)
    {
        if (string.IsNullOrWhiteSpace(skills))
        {
            return true;
        }

        var tokens = skills.Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        return tokens.All(token => System.Text.RegularExpressions.Regex.IsMatch(token, ValidationPatterns.SkillToken));
    }
}
