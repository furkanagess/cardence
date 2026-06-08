using System.Security.Claims;
using Cardence.Application.Interfaces;
using Microsoft.AspNetCore.Http;

namespace Cardence.Infrastructure.Auth;

public sealed class CurrentUserService : ICurrentUserService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public CurrentUserService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid? UserId
    {
        get
        {
            var sub = _httpContextAccessor.HttpContext?.User.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? _httpContextAccessor.HttpContext?.User.FindFirstValue("sub");

            return Guid.TryParse(sub, out var userId) ? userId : null;
        }
    }

    public Guid GetRequiredUserId()
    {
        return UserId ?? throw new UnauthorizedAccessException();
    }
}
