namespace Cardence.Application.Interfaces;

public interface IUploadContentStore
{
    Task SaveFileAsync(
        string relativeKey,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default);

    Task<Stream?> OpenReadAsync(
        string relativeKey,
        CancellationToken cancellationToken = default);

    Task DeleteMatchingFilesAsync(
        string relativeDirectory,
        string fileNamePrefix,
        CancellationToken cancellationToken = default);
}
