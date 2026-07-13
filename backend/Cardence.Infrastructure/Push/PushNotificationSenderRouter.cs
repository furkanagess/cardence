using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Push;

public sealed class PushNotificationSenderRouter : IPushNotificationSender
{
    private readonly IServiceProvider _serviceProvider;
    private readonly PushNotificationOptions _options;

    public PushNotificationSenderRouter(
        IServiceProvider serviceProvider,
        IOptions<PushNotificationOptions> options)
    {
        _serviceProvider = serviceProvider;
        _options = options.Value;
    }

    public Task<PushNotificationSendResult> SendAsync(
        IReadOnlyList<string> deviceTokens,
        string title,
        string body,
        IReadOnlyDictionary<string, string> data,
        CancellationToken cancellationToken = default)
    {
        var sender = ResolveSender();
        return sender.SendAsync(deviceTokens, title, body, data, cancellationToken);
    }

    private IPushNotificationSender ResolveSender()
    {
        return _options.IsConfigured
            ? _serviceProvider.GetRequiredService<FcmPushNotificationSender>()
            : _serviceProvider.GetRequiredService<LoggingPushNotificationSender>();
    }
}
