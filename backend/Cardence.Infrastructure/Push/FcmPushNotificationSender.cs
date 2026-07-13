using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Push;

public sealed class FcmPushNotificationSender : IPushNotificationSender
{
    private readonly ILogger<FcmPushNotificationSender> _logger;
    private readonly object _initLock = new();
    private bool _initialized;

    public FcmPushNotificationSender(
        IOptions<PushNotificationOptions> options,
        ILogger<FcmPushNotificationSender> logger)
    {
        _logger = logger;
        EnsureFirebaseApp(options.Value);
    }

    public async Task<PushNotificationSendResult> SendAsync(
        IReadOnlyList<string> deviceTokens,
        string title,
        string body,
        IReadOnlyDictionary<string, string> data,
        CancellationToken cancellationToken = default)
    {
        if (deviceTokens.Count == 0)
        {
            return new PushNotificationSendResult();
        }

        var message = new MulticastMessage
        {
            Tokens = deviceTokens.ToList(),
            Notification = new Notification
            {
                Title = title,
                Body = body,
            },
            Data = data.ToDictionary(
                pair => pair.Key,
                pair => pair.Value,
                StringComparer.Ordinal),
            Android = new AndroidConfig
            {
                Priority = Priority.High,
                Notification = new AndroidNotification
                {
                    ChannelId = "cardence_default",
                    Sound = "default",
                },
            },
            Apns = new ApnsConfig
            {
                Aps = new Aps
                {
                    Sound = "default",
                },
            },
        };

        var response = await FirebaseMessaging.DefaultInstance
            .SendEachForMulticastAsync(message, cancellationToken);

        var invalidTokens = new List<string>();
        for (var index = 0; index < response.Responses.Count; index++)
        {
            var sendResponse = response.Responses[index];
            if (sendResponse.IsSuccess)
            {
                continue;
            }

            var token = deviceTokens[index];
            var errorCode = sendResponse.Exception?.MessagingErrorCode;
            if (errorCode is MessagingErrorCode.Unregistered or MessagingErrorCode.InvalidArgument)
            {
                invalidTokens.Add(token);
            }

            _logger.LogWarning(
                sendResponse.Exception,
                "FCM send failed for token index {Index}: {ErrorCode}",
                index,
                errorCode);
        }

        return new PushNotificationSendResult
        {
            InvalidTokens = invalidTokens,
        };
    }

    private void EnsureFirebaseApp(PushNotificationOptions options)
    {
        if (_initialized || FirebaseApp.DefaultInstance is not null)
        {
            _initialized = true;
            return;
        }

        lock (_initLock)
        {
            if (_initialized || FirebaseApp.DefaultInstance is not null)
            {
                _initialized = true;
                return;
            }

            GoogleCredential credential;
            if (!string.IsNullOrWhiteSpace(options.ServiceAccountJson))
            {
                credential = GoogleCredential.FromJson(options.ServiceAccountJson);
            }
            else if (!string.IsNullOrWhiteSpace(options.ServiceAccountPath))
            {
                credential = GoogleCredential.FromFile(options.ServiceAccountPath);
            }
            else
            {
                throw new InvalidOperationException(
                    "PushNotifications is not configured with service account credentials.");
            }

            FirebaseApp.Create(new AppOptions
            {
                Credential = credential,
            });
            _initialized = true;
        }
    }
}
