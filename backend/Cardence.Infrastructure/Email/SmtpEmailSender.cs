using System.Net;
using System.Net.Mail;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Email;

public sealed class SmtpEmailSender : IEmailSender
{
    private readonly EmailOptions _options;
    private readonly ILogger<SmtpEmailSender> _logger;

    public SmtpEmailSender(IOptions<EmailOptions> options, ILogger<SmtpEmailSender> logger)
    {
        _options = options.Value;
        _logger = logger;
    }

    public async Task SendPasswordResetEmailAsync(
        string toEmail,
        string resetUrl,
        CancellationToken cancellationToken = default)
    {
        if (!_options.IsConfigured)
        {
            throw new InvalidOperationException("SMTP email is not configured.");
        }

        using var message = BuildMessage(toEmail, resetUrl);
        using var client = new SmtpClient(_options.SmtpHost, _options.SmtpPort)
        {
            EnableSsl = _options.UseSsl,
            DeliveryMethod = SmtpDeliveryMethod.Network,
            Credentials = new NetworkCredential(
                _options.SmtpUsername,
                _options.SmtpPassword),
        };

        cancellationToken.ThrowIfCancellationRequested();
        await client.SendMailAsync(message, cancellationToken);

        _logger.LogInformation("Password reset email sent to {Email}", toEmail);
    }

    private MailMessage BuildMessage(string toEmail, string resetUrl)
    {
        var message = new MailMessage
        {
            From = new MailAddress(_options.FromAddress, _options.FromName),
            Subject = "Cardence şifre sıfırlama bağlantınız",
            Body = BuildHtmlBody(resetUrl),
            IsBodyHtml = true,
        };
        message.To.Add(toEmail);
        return message;
    }

    private static string BuildHtmlBody(string resetUrl)
    {
        return $"""
            <!DOCTYPE html>
            <html lang="tr">
            <head><meta charset="utf-8" /></head>
            <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; color: #1c2430;">
              <h2>Şifrenizi sıfırlayın</h2>
              <p>Cardence hesabınız için şifre sıfırlama talebi aldık.</p>
              <p><a href="{WebUtility.HtmlEncode(resetUrl)}">Şifremi sıfırla</a></p>
              <p>Bu bağlantı 30 dakika boyunca geçerlidir.</p>
              <p>Bu isteği siz yapmadıysanız bu e-postayı yok sayabilirsiniz.</p>
            </body>
            </html>
            """;
    }
}
