namespace Cardence.Application.Common;

public static class AuthErrorCodes
{
    public const int None = 0;
    public const int InvalidRequest = 1001;
    public const int InvalidCredentials = 1002;
    public const int InvalidOtp = 1003;
    public const int OtpExpired = 1004;
    public const int UserNotFound = 1005;
    public const int InvalidRefreshToken = 1006;
    public const int UserAlreadyExists = 1007;
}
