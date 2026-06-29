using Cardence.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace Cardence.Infrastructure.Email;

/// <summary>
/// SMTP yapılandırılmadığında geliştirme ortamında reset linkini loglar.
/// </summary>
public sealed class LoggingEmailSender : IEmailSender
{
    private readonly ILogger<LoggingEmailSender> _logger;

    public LoggingEmailSender(ILogger<LoggingEmailSender> logger)
    {
        _logger = logger;
    }

    public Task SendPasswordResetEmailAsync(
        string toEmail,
        string resetUrl,
        CancellationToken cancellationToken = default)
    {
        _logger.LogWarning(
            "SMTP not configured. Password reset link for {Email}: {ResetUrl}",
            toEmail,
            resetUrl);
        return Task.CompletedTask;
    }
}
