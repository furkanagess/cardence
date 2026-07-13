namespace Cardence.Application.Interfaces;

public interface IPushNotificationSender
{
    Task<PushNotificationSendResult> SendAsync(
        IReadOnlyList<string> deviceTokens,
        string title,
        string body,
        IReadOnlyDictionary<string, string> data,
        CancellationToken cancellationToken = default);
}

public sealed class PushNotificationSendResult
{
    public IReadOnlyList<string> InvalidTokens { get; init; } = [];
}
