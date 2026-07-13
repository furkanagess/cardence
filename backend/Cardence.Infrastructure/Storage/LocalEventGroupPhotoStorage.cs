using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Storage;

public sealed class LocalEventGroupPhotoStorage : IEventGroupPhotoStorage
{
    private readonly IUploadContentStore _contentStore;
    private readonly string _publicBaseUrl;

    public LocalEventGroupPhotoStorage(
        IUploadContentStore contentStore,
        IOptions<ApiOptions> apiOptions)
    {
        _contentStore = contentStore;
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

        var relativeDirectory = $"users/{userId:D}/event-groups";
        await _contentStore.DeleteMatchingFilesAsync(
            relativeDirectory,
            groupId.ToString("D"),
            cancellationToken);

        var variants = await MediaImageProcessor.CreateEventGroupVariantsAsync(
            content,
            groupId,
            cancellationToken);

        foreach (var (fileName, bytes) in variants)
        {
            await using var stream = new MemoryStream(bytes);
            await _contentStore.SaveFileAsync(
                $"{relativeDirectory}/{fileName}",
                stream,
                "image/jpeg",
                cancellationToken);
        }

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
        return _contentStore.DeleteMatchingFilesAsync(
            $"users/{userId:D}/event-groups",
            groupId.ToString("D"),
            cancellationToken);
    }
}
