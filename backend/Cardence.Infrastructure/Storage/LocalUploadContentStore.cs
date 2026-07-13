using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Storage;

public sealed class LocalUploadContentStore : IUploadContentStore
{
    private readonly string _rootPath;

    public LocalUploadContentStore(
        IHostEnvironment environment,
        IOptions<ObjectStorageOptions> options)
    {
        var configured = options.Value.LocalRootPath.Trim();
        _rootPath = Path.IsPathRooted(configured)
            ? configured
            : Path.Combine(environment.ContentRootPath, configured);
        Directory.CreateDirectory(_rootPath);
    }

    public async Task SaveFileAsync(
        string relativeKey,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default)
    {
        _ = contentType;
        var fullPath = GetFullPath(relativeKey);
        var directory = Path.GetDirectoryName(fullPath);
        if (!string.IsNullOrWhiteSpace(directory))
        {
            Directory.CreateDirectory(directory);
        }

        await using var file = File.Create(fullPath);
        content.Position = 0;
        await content.CopyToAsync(file, cancellationToken);
    }

    public Task<Stream?> OpenReadAsync(
        string relativeKey,
        CancellationToken cancellationToken = default)
    {
        _ = cancellationToken;
        var fullPath = GetFullPath(relativeKey);
        if (!File.Exists(fullPath))
        {
            return Task.FromResult<Stream?>(null);
        }

        return Task.FromResult<Stream?>(File.OpenRead(fullPath));
    }

    public Task DeleteMatchingFilesAsync(
        string relativeDirectory,
        string fileNamePrefix,
        CancellationToken cancellationToken = default)
    {
        _ = cancellationToken;
        var directory = GetFullPath(relativeDirectory);
        if (!Directory.Exists(directory))
        {
            return Task.CompletedTask;
        }

        foreach (var file in Directory.EnumerateFiles(directory, $"{fileNamePrefix}*"))
        {
            File.Delete(file);
        }

        return Task.CompletedTask;
    }

    private string GetFullPath(string relativeKey)
    {
        var normalized = relativeKey
            .Replace('\\', '/')
            .TrimStart('/');
        return Path.Combine(_rootPath, normalized.Replace('/', Path.DirectorySeparatorChar));
    }
}
