using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Storage;

/// <summary>
/// Yerel diske her zaman yazar/okur; S3 yapılandırıldıysa ikincil depo olarak kullanır.
/// Railway volume + S3 geçişinde dosyalar kaybolmaz.
/// </summary>
public sealed class ResilientUploadContentStore : IUploadContentStore
{
    private readonly LocalUploadContentStore _local;
    private readonly S3UploadContentStore? _s3;
    private readonly ObjectStorageOptions _options;

    public ResilientUploadContentStore(
        LocalUploadContentStore local,
        IOptions<ObjectStorageOptions> options,
        S3UploadContentStore? s3 = null)
    {
        _local = local;
        _options = options.Value;
        _s3 = _options.UseS3 ? s3 : null;
    }

    public async Task SaveFileAsync(
        string relativeKey,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        await using var localCopy = await CopyStreamAsync(content, cancellationToken);
        await _local.SaveFileAsync(relativeKey, localCopy, contentType, cancellationToken);

        if (_s3 is null)
        {
            return;
        }

        localCopy.Position = 0;
        await _s3.SaveFileAsync(relativeKey, localCopy, contentType, cancellationToken);
    }

    public async Task<Stream?> OpenReadAsync(
        string relativeKey,
        CancellationToken cancellationToken = default)
    {
        var local = await _local.OpenReadAsync(relativeKey, cancellationToken);
        if (local is not null)
        {
            return local;
        }

        return _s3 is null
            ? null
            : await _s3.OpenReadAsync(relativeKey, cancellationToken);
    }

    public async Task DeleteMatchingFilesAsync(
        string relativeDirectory,
        string fileNamePrefix,
        CancellationToken cancellationToken = default)
    {
        await _local.DeleteMatchingFilesAsync(
            relativeDirectory,
            fileNamePrefix,
            cancellationToken);

        if (_s3 is not null)
        {
            await _s3.DeleteMatchingFilesAsync(
                relativeDirectory,
                fileNamePrefix,
                cancellationToken);
        }
    }

    private static async Task<MemoryStream> CopyStreamAsync(
        Stream content,
        CancellationToken cancellationToken)
    {
        var memory = new MemoryStream();
        content.Position = 0;
        await content.CopyToAsync(memory, cancellationToken);
        memory.Position = 0;
        return memory;
    }
}
