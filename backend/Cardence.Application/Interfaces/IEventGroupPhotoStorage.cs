namespace Cardence.Application.Interfaces;

public interface IEventGroupPhotoStorage
{
    Task<string> SaveEventGroupPhotoAsync(
        Guid userId,
        Guid groupId,
        Stream content,
        string contentType,
        CancellationToken cancellationToken = default);

    Task DeleteEventGroupPhotoAsync(
        Guid userId,
        Guid groupId,
        CancellationToken cancellationToken = default);
}
