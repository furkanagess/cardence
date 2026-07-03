namespace Cardence.Application.Common;

/// <summary>
/// Yüklenen medya dosyaları için tutarlı URL üretimi.
/// </summary>
public static class MediaUrlBuilder
{
    public static string ProfilePhotoUrl(string publicBaseUrl, Guid userId, int variantWidth, long version)
    {
        var baseUrl = publicBaseUrl.TrimEnd('/');
        return $"{baseUrl}/uploads/users/{userId:D}/profile-{variantWidth}.jpg?v={version}";
    }

    public static string EventGroupPhotoUrl(
        string publicBaseUrl,
        Guid userId,
        Guid groupId,
        int variantWidth,
        long version)
    {
        var baseUrl = publicBaseUrl.TrimEnd('/');
        return
            $"{baseUrl}/uploads/users/{userId:D}/event-groups/{groupId:D}-{variantWidth}.jpg?v={version}";
    }

    public static bool IsProfilePhotoFile(string fileName)
    {
        if (fileName.StartsWith("profile.", StringComparison.OrdinalIgnoreCase))
        {
            return true;
        }

        return fileName.StartsWith("profile-", StringComparison.OrdinalIgnoreCase)
            && fileName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase);
    }

    public static bool IsEventGroupPhotoFile(string fileName)
    {
        return fileName.Contains('-', StringComparison.Ordinal)
            && fileName.EndsWith(".jpg", StringComparison.OrdinalIgnoreCase);
    }
}
