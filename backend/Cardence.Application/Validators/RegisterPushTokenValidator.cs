using Cardence.Application.DTOs.Notifications;
using FluentValidation;

namespace Cardence.Application.Validators;

public sealed class RegisterPushTokenValidator : AbstractValidator<RegisterPushTokenRequest>
{
  private static readonly HashSet<string> AllowedPlatforms = new(StringComparer.OrdinalIgnoreCase)
  {
    "ios",
    "android",
    "web",
  };

  public RegisterPushTokenValidator()
  {
    RuleFor(x => x.Token)
      .NotEmpty()
      .MaximumLength(512);

    RuleFor(x => x.Platform)
      .NotEmpty()
      .MaximumLength(20)
      .Must(platform => AllowedPlatforms.Contains(platform))
      .WithMessage("Platform must be ios, android, or web.");
  }
}
