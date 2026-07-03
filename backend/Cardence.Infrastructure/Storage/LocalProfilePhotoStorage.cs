using Cardence.Application.Common;
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
        _ = contentType;

        var userDir = Path.Combine(_uploadRoot, "users", userId.ToString("D"));
        await MediaImageProcessor.SaveProfileVariantsAsync(content, userDir, cancellationToken);

        var version = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        return MediaUrlBuilder.ProfilePhotoUrl(
            _publicBaseUrl,
            userId,
            MediaVariantWidths.DefaultCard,
            version);
    }
}
