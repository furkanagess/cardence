using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Net;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Email;

/// <summary>
/// SendGrid v3 Web API (HTTPS/443) üzerinden mail gönderir.
/// Bulut sağlayıcılar (Railway vb.) giden SMTP portlarını (587/465/25) sık sık
/// engellediği için production'da SMTP yerine bu transport kullanılır.
/// API key, EmailOptions.SmtpPassword (SG.xxx) alanından okunur.
/// </summary>
public sealed class SendGridApiEmailSender : IEmailSender
{
    private const string SendEndpoint = "https://api.sendgrid.com/v3/mail/send";

    private readonly HttpClient _httpClient;
    private readonly EmailOptions _options;
    private readonly ILogger<SendGridApiEmailSender> _logger;

    public SendGridApiEmailSender(
        HttpClient httpClient,
        IOptions<EmailOptions> options,
        ILogger<SendGridApiEmailSender> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public async Task SendPasswordResetEmailAsync(
        string toEmail,
        string resetUrl,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.SmtpPassword))
        {
            throw new InvalidOperationException("SendGrid API key is not configured.");
        }

        var payload = new
        {
            personalizations = new[]
            {
                new { to = new[] { new { email = toEmail } } },
            },
            from = new { email = _options.FromAddress, name = _options.FromName },
            subject = "Cardence şifre sıfırlama bağlantınız",
            content = new[]
            {
                new { type = "text/html", value = BuildHtmlBody(resetUrl) },
            },
        };

        using var request = new HttpRequestMessage(HttpMethod.Post, SendEndpoint)
        {
            Content = JsonContent.Create(payload),
        };
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _options.SmtpPassword);

        using var response = await _httpClient.SendAsync(request, cancellationToken);

        if (response.StatusCode is HttpStatusCode.OK or HttpStatusCode.Accepted)
        {
            _logger.LogInformation("Password reset email sent to {Email} via SendGrid API", toEmail);
            return;
        }

        var body = await response.Content.ReadAsStringAsync(cancellationToken);
        _logger.LogError(
            "SendGrid API responded {StatusCode} for {Email}: {Body}",
            (int)response.StatusCode,
            toEmail,
            body);
        throw new InvalidOperationException(
            $"SendGrid API request failed with status {(int)response.StatusCode}.");
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
