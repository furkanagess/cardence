using Cardence.Application.Interfaces;
using Microsoft.Extensions.Logging;

namespace Cardence.Infrastructure.Push;

/// <summary>
/// FCM yapılandırılmadığında bildirim içeriğini loglar.
/// </summary>
public sealed class LoggingPushNotificationSender : IPushNotificationSender
{
    private readonly ILogger<LoggingPushNotificationSender> _logger;

    public LoggingPushNotificationSender(ILogger<LoggingPushNotificationSender> logger)
    {
        _logger = logger;
    }

    public Task<PushNotificationSendResult> SendAsync(
        IReadOnlyList<string> deviceTokens,
        string title,
        string body,
        IReadOnlyDictionary<string, string> data,
        CancellationToken cancellationToken = default)
    {
        _logger.LogInformation(
            "Push notification (dev): tokens={TokenCount}, title={Title}, body={Body}, data={Data}",
            deviceTokens.Count,
            title,
            body,
            string.Join(", ", data.Select(pair => $"{pair.Key}={pair.Value}")));

        return Task.FromResult(new PushNotificationSendResult());
    }
}
