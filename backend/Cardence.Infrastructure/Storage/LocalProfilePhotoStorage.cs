using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Storage;

public sealed class LocalProfilePhotoStorage : IProfilePhotoStorage
{
    private readonly IUploadContentStore _contentStore;
    private readonly string _publicBaseUrl;

    public LocalProfilePhotoStorage(
        IUploadContentStore contentStore,
        IOptions<ApiOptions> apiOptions)
    {
        _contentStore = contentStore;
        _publicBaseUrl = apiOptions.Value.PublicBaseUrl.TrimEnd('/');
    }

    public async Task<string> SaveProfilePhotoAsync(
        Guid userId,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        _ = contentType;

        var relativeDirectory = $"users/{userId:D}";
        await _contentStore.DeleteMatchingFilesAsync(
            relativeDirectory,
            "profile",
            cancellationToken);

        var variants = await MediaImageProcessor.CreateProfileVariantsAsync(
            content,
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
        return MediaUrlBuilder.ProfilePhotoUrl(
            _publicBaseUrl,
            userId,
            MediaVariantWidths.DefaultCard,
            version);
    }
}
