using Cardence.Application.Common;
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
        _ = contentType;

        var groupDir = Path.Combine(
            _uploadRoot,
            "users",
            userId.ToString("D"),
            "event-groups");
        await MediaImageProcessor.SaveEventGroupVariantsAsync(
            content,
            groupDir,
            groupId,
            cancellationToken);

        var version = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        return MediaUrlBuilder.EventGroupPhotoUrl(
            _publicBaseUrl,
            userId,
            groupId,
            MediaVariantWidths.DefaultEventCover,
            version);
    }

    public Task DeleteEventGroupPhotoAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default)
    {
        _ = cancellationToken;

        var groupDir = Path.Combine(
            _uploadRoot,
            "users",
            userId.ToString("D"),
            "event-groups");
        if (!Directory.Exists(groupDir))
        {
            return Task.CompletedTask;
        }

        var prefix = $"{groupId:D}";
        foreach (var file in Directory.EnumerateFiles(groupDir, $"{prefix}*"))
        {
            File.Delete(file);
        }

        return Task.CompletedTask;
    }
}
