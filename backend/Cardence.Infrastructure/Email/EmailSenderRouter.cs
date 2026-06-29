using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Email;

public sealed class EmailSenderRouter : IEmailSender
{
    private readonly IServiceProvider _serviceProvider;
    private readonly EmailOptions _options;

    public EmailSenderRouter(IServiceProvider serviceProvider, IOptions<EmailOptions> options)
    {
        _serviceProvider = serviceProvider;
        _options = options.Value;
    }

    public Task SendPasswordResetEmailAsync(
        string toEmail,
        string resetUrl,
        CancellationToken cancellationToken = default)
    {
        IEmailSender sender = ResolveSender();
        return sender.SendPasswordResetEmailAsync(toEmail, resetUrl, cancellationToken);
    }

    private IEmailSender ResolveSender()
    {
        if (!_options.IsConfigured)
        {
            return _serviceProvider.GetRequiredService<LoggingEmailSender>();
        }

        // Bulut sağlayıcılar giden SMTP portlarını engellediği için SendGrid'de
        // HTTPS (443) tabanlı Web API tercih edilir; diğer hostlarda klasik SMTP.
        var usesSendGrid = _options.SmtpHost.Contains("sendgrid", StringComparison.OrdinalIgnoreCase);
        return usesSendGrid
            ? _serviceProvider.GetRequiredService<SendGridApiEmailSender>()
            : _serviceProvider.GetRequiredService<SmtpEmailSender>();
    }
}
