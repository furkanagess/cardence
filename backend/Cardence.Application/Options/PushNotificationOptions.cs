namespace Cardence.Application.Options;

public sealed class PushNotificationOptions
{
    public const string SectionName = "PushNotifications";

    /// <summary>
    /// Firebase service account JSON (inline). Production'da environment variable ile verilir.
    /// </summary>
    public string ServiceAccountJson { get; init; } = string.Empty;

    /// <summary>
    /// Firebase service account JSON dosya yolu (geliştirme ortamı).
    /// </summary>
    public string ServiceAccountPath { get; init; } = string.Empty;

    public bool IsConfigured =>
        !string.IsNullOrWhiteSpace(ServiceAccountJson) ||
        !string.IsNullOrWhiteSpace(ServiceAccountPath);
}
