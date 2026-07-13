namespace Cardence.Application.Options;

public sealed class ObjectStorageOptions
{
    public const string SectionName = "ObjectStorage";

    /// <summary>
    /// local | s3
    /// </summary>
    public string Provider { get; init; } = "local";

    public string Bucket { get; init; } = string.Empty;
    public string Region { get; init; } = "auto";
    public string Endpoint { get; init; } = string.Empty;
    public string AccessKeyId { get; init; } = string.Empty;
    public string SecretAccessKey { get; init; } = string.Empty;

    /// <summary>
    /// Yerel geliştirmede uploads kökü. Production'da Railway volume mount: /app/uploads
    /// </summary>
    public string LocalRootPath { get; init; } = "uploads";

    public bool UseS3 =>
        Provider.Equals("s3", StringComparison.OrdinalIgnoreCase)
        && !string.IsNullOrWhiteSpace(Bucket)
        && !string.IsNullOrWhiteSpace(AccessKeyId)
        && !string.IsNullOrWhiteSpace(SecretAccessKey);
}
