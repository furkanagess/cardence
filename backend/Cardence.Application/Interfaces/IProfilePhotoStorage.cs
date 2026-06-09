namespace Cardence.Application.Interfaces;

public interface IProfilePhotoStorage
{
    Task<string> SaveProfilePhotoAsync(
        Guid userId,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default);
}
