using Cardence.Domain.Entities;

namespace Cardence.Application.Interfaces;

public interface IJwtTokenService
{
    string CreateAccessToken(User user);
    string CreateRefreshToken();
}
