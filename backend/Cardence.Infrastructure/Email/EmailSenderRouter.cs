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
        IEmailSender sender = _options.IsConfigured
            ? _serviceProvider.GetRequiredService<SmtpEmailSender>()
            : _serviceProvider.GetRequiredService<LoggingEmailSender>();

        return sender.SendPasswordResetEmailAsync(toEmail, resetUrl, cancellationToken);
    }
}
