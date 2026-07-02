using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Storage;

public sealed class LocalEventGroupPhotoStorage : IEventGroupPhotoStorage
{
    private readonly string _uploadRoot;
    private readonly string _publicBaseUrl;

    public LocalEventGroupPhotoStorage(
        IHostEnvironment environment,
        IOptions<ApiOptions> apiOptions)
    {
        _uploadRoot = Path.Combine(environment.ContentRootPath, "uploads");
        _publicBaseUrl = apiOptions.Value.PublicBaseUrl.TrimEnd('/');
    }

    public async Task<string> SaveEventGroupPhotoAsync(
        Guid userId,
        Guid groupId,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        var extension = ResolveExtension(contentType);
        var groupDir = Path.Combine(
            _uploadRoot,
            "users",
            userId.ToString("D"),
            "event-groups");
        Directory.CreateDirectory(groupDir);

        await DeleteExistingFilesAsync(groupDir, groupId);

        var fileName = $"{groupId:D}{extension}";
        var absolutePath = Path.Combine(groupDir, fileName);

        await using (var fileStream = new FileStream(
            absolutePath,
            FileMode.Create,
            FileAccess.Write,
            FileShare.None))
        {
            await content.CopyToAsync(fileStream, cancellationToken);
        }

        return
            $"{_publicBaseUrl}/uploads/users/{userId:D}/event-groups/{fileName}?v={DateTimeOffset.UtcNow.ToUnixTimeSeconds()}";
    }

    public Task DeleteEventGroupPhotoAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        var groupDir = Path.Combine(
            _uploadRoot,
            "users",
            userId.ToString("D"),
            "event-groups");
        return DeleteExistingFilesAsync(groupDir, groupId);
    }

    private static Task DeleteExistingFilesAsync(string groupDir, Guid groupId)
    {
        if (!Directory.Exists(groupDir))
        {
            return Task.CompletedTask;
        }

        var prefix = $"{groupId:D}";
        foreach (var file in Directory.EnumerateFiles(groupDir, $"{prefix}.*"))
        {
            File.Delete(file);
        }

        return Task.CompletedTask;
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
