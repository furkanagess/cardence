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

    public static bool IsPublicUploadPath(string? path)
    {
        return IsPublicProfilePhotoPath(path) || IsPublicEventGroupPhotoPath(path);
    }

    public static bool IsPublicProfilePhotoPath(string? path)
    {
        var value = NormalizePath(path);
        if (string.IsNullOrEmpty(value))
        {
            return false;
        }

        var segments = value.Split('/', StringSplitOptions.RemoveEmptyEntries);
        if (segments.Length != 4)
        {
            return false;
        }

        if (!segments[0].Equals("uploads", StringComparison.OrdinalIgnoreCase)
            || !segments[1].Equals("users", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        if (!IsUserIdSegment(segments[2]))
        {
            return false;
        }

        return IsProfilePhotoFile(segments[3]);
    }

    public static bool IsPublicEventGroupPhotoPath(string? path)
    {
        var value = NormalizePath(path);
        if (string.IsNullOrEmpty(value))
        {
            return false;
        }

        var segments = value.Split('/', StringSplitOptions.RemoveEmptyEntries);
        if (segments.Length != 5)
        {
            return false;
        }

        if (!segments[0].Equals("uploads", StringComparison.OrdinalIgnoreCase)
            || !segments[1].Equals("users", StringComparison.OrdinalIgnoreCase)
            || !segments[3].Equals("event-groups", StringComparison.OrdinalIgnoreCase))
        {
            return false;
        }

        if (!IsUserIdSegment(segments[2]))
        {
            return false;
        }

        return IsEventGroupPhotoFile(segments[4]);
    }

    private static string? NormalizePath(string? path)
    {
        if (string.IsNullOrWhiteSpace(path))
        {
            return null;
        }

        return path.StartsWith('/') ? path : $"/{path}";
    }

    private static bool IsUserIdSegment(string segment)
    {
        if (Guid.TryParse(segment, out _))
        {
            return true;
        }

        if (segment.Length != 32)
        {
            return false;
        }

        foreach (var ch in segment)
        {
            if (!Uri.IsHexDigit(ch))
            {
                return false;
            }
        }

        return true;
    }
}
