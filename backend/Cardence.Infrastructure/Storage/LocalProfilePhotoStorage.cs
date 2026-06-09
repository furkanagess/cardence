using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Storage;

public sealed class LocalProfilePhotoStorage : IProfilePhotoStorage
{
    private readonly string _uploadRoot;
    private readonly string _publicBaseUrl;

    public LocalProfilePhotoStorage(
        IHostEnvironment environment,
        IOptions<ApiOptions> apiOptions)
    {
        _uploadRoot = Path.Combine(environment.ContentRootPath, "uploads");
        _publicBaseUrl = apiOptions.Value.PublicBaseUrl.TrimEnd('/');
    }

    public async Task<string> SaveProfilePhotoAsync(
        Guid userId,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        var extension = ResolveExtension(contentType);
        var userDir = Path.Combine(_uploadRoot, "users", userId.ToString("D"));
        Directory.CreateDirectory(userDir);

        var fileName = $"profile{extension}";
        var absolutePath = Path.Combine(userDir, fileName);

        await using (var fileStream = new FileStream(
            absolutePath,
            FileMode.Create,
            FileAccess.Write,
            FileShare.None))
        {
            await content.CopyToAsync(fileStream, cancellationToken);
        }

        return $"{_publicBaseUrl}/uploads/users/{userId:D}/{fileName}";
    }

    private static string ResolveExtension(string contentType)
    {
        return contentType.ToLowerInvariant() switch
        {
            "image/png" => ".png",
            "image/webp" => ".webp",
            "image/jpeg" or "image/jpg" => ".jpg",
            _ => ".jpg",
        };
    }
}
