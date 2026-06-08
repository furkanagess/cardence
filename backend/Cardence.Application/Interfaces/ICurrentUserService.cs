namespace Cardence.Application.Interfaces;

public interface ICurrentUserService
{
    Guid? UserId { get; }
    Guid GetRequiredUserId();
}
