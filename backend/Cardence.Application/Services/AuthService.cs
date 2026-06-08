using Cardence.Application.Common;
using Cardence.Application.DTOs.Auth;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Cardence.Domain.Entities;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Application.Services;

public sealed class AuthService : IAuthService
{
    private const int MinPasswordLength = 8;
    private static readonly TimeSpan OtpLifetime = TimeSpan.FromMinutes(5);

    private readonly IUserRepository _userRepository;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IAuthTokenStore _authTokenStore;
    private readonly IPasswordHasher _passwordHasher;
    private readonly JwtOptions _jwtOptions;
    private readonly ILogger<AuthService> _logger;

    public AuthService(
        IUserRepository userRepository,
        IJwtTokenService jwtTokenService,
        IAuthTokenStore authTokenStore,
        IPasswordHasher passwordHasher,
        IOptions<JwtOptions> jwtOptions,
        ILogger<AuthService> logger)
    {
        _userRepository = userRepository;
        _jwtTokenService = jwtTokenService;
        _authTokenStore = authTokenStore;
        _passwordHasher = passwordHasher;
        _jwtOptions = jwtOptions.Value;
        _logger = logger;
    }

    public async Task<AuthServiceResponse<AuthSessionEntity>> AuthenticationAsync(
        AuthenticationRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "E-posta gereklidir.");
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Şifre gereklidir.");
        }

        var email = request.Email.Trim().ToLowerInvariant();
        var user = await _userRepository.GetByEmailAsync(email, cancellationToken);
        if (user is null)
        {
            return FailSession(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "Bu e-posta ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.");
        }

        if (!VerifyPassword(request.Password, user.PasswordHash))
        {
            return FailSession(
                AuthErrorCodes.InvalidCredentials,
                "InvalidCredentials",
                "E-posta veya şifre hatalı.");
        }

        return await CreateSessionAsync(user, "Giriş başarılı.", cancellationToken);
    }

    public async Task<AuthServiceResponse<AuthSessionEntity>> LoginWithPhoneAsync(
        LoginWithPhoneRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Phone))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Telefon gereklidir.");
        }

        var phone = NormalizePhone(request.Phone);

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            var user = await _userRepository.GetByPhoneAsync(phone, cancellationToken);
            if (user is null)
            {
                return FailSession(
                    AuthErrorCodes.UserNotFound,
                    "UserNotFound",
                    "Bu telefon ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.");
            }

            if (!VerifyPassword(request.Password, user.PasswordHash))
            {
                return FailSession(
                    AuthErrorCodes.InvalidCredentials,
                    "InvalidCredentials",
                    "Telefon veya şifre hatalı.");
            }

            return await CreateSessionAsync(user, "Giriş başarılı.", cancellationToken);
        }

        if (string.IsNullOrWhiteSpace(request.OtpCode))
        {
            var otpResult = await SendPhoneOtpInternalAsync(phone, cancellationToken);
            if (!otpResult.Success)
            {
                return FailSession(
                    otpResult.Error.Code,
                    otpResult.Error.Description,
                    otpResult.Message);
            }

            return AuthServiceResponse<AuthSessionEntity>.Ok(
                default,
                otpResult.Message);
        }

        var otpKey = BuildPhoneOtpKey(phone);

        if (!await _authTokenStore.ValidateOtpAsync(otpKey, request.OtpCode, cancellationToken))
        {
            return FailSession(
                AuthErrorCodes.InvalidOtp,
                "InvalidOtp",
                "OTP code is invalid or expired.");
        }

        var otpUser = await _userRepository.GetByPhoneAsync(phone, cancellationToken);
        if (otpUser is null)
        {
            return FailSession(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "Bu telefon ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.");
        }

        return await CreateSessionAsync(otpUser, "Phone login successful.", cancellationToken);
    }

    public async Task<AuthServiceResponse<AuthSessionEntity>> LoginWithEmailAsync(
        LoginWithEmailRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "E-posta gereklidir.");
        }

        var email = request.Email.Trim().ToLowerInvariant();

        if (!string.IsNullOrWhiteSpace(request.Password))
        {
            var user = await _userRepository.GetByEmailAsync(email, cancellationToken);
            if (user is null)
            {
                return FailSession(
                    AuthErrorCodes.UserNotFound,
                    "UserNotFound",
                    "Bu e-posta ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.");
            }

            if (!VerifyPassword(request.Password, user.PasswordHash))
            {
                return FailSession(
                    AuthErrorCodes.InvalidCredentials,
                    "InvalidCredentials",
                    "E-posta veya şifre hatalı.");
            }

            return await CreateSessionAsync(user, "Giriş başarılı.", cancellationToken);
        }

        if (string.IsNullOrWhiteSpace(request.OtpCode))
        {
            var otpResult = await SendEmailOtpInternalAsync(email, cancellationToken);
            if (!otpResult.Success)
            {
                return FailSession(
                    otpResult.Error.Code,
                    otpResult.Error.Description,
                    otpResult.Message);
            }

            return AuthServiceResponse<AuthSessionEntity>.Ok(
                default,
                otpResult.Message);
        }

        var otpKey = BuildEmailOtpKey(email);

        if (!await _authTokenStore.ValidateOtpAsync(otpKey, request.OtpCode, cancellationToken))
        {
            return FailSession(
                AuthErrorCodes.InvalidOtp,
                "InvalidOtp",
                "OTP code is invalid or expired.");
        }

        var otpUser = await _userRepository.GetByEmailAsync(email, cancellationToken);
        if (otpUser is null)
        {
            return FailSession(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "Bu e-posta ile kayıtlı kullanıcı bulunamadı. Önce kayıt olun.");
        }

        return await CreateSessionAsync(otpUser, "Email login successful.", cancellationToken);
    }

    public Task<AuthServiceResponse<object?>> SendOtpAsync(
        SendOtpRequest request,
        CancellationToken cancellationToken = default)
    {
        return SendPhoneOtpInternalAsync(request.Phone, cancellationToken);
    }

    public async Task<AuthServiceResponse<AuthSessionEntity>> RefreshAuthenticationAsync(
        RefreshAuthenticationRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.RefreshToken))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "RefreshToken is required.");
        }

        var userId = await _authTokenStore.GetUserIdByRefreshTokenAsync(
            request.RefreshToken.Trim(),
            cancellationToken);

        if (userId is null)
        {
            return FailSession(
                AuthErrorCodes.InvalidRefreshToken,
                "InvalidRefreshToken",
                "Refresh token is invalid or expired.");
        }

        var user = await _userRepository.GetByIdAsync(userId.Value, cancellationToken);
        if (user is null)
        {
            return FailSession(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "User not found.");
        }

        return await CreateSessionAsync(user, "Token refreshed.", cancellationToken);
    }

    public async Task<AuthServiceResponse<AuthSessionEntity>> RegisterAsync(
        RegisterRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.DisplayName))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Ad soyad gereklidir.");
        }

        if (string.IsNullOrWhiteSpace(request.Email))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "E-posta gereklidir.");
        }

        if (string.IsNullOrWhiteSpace(request.Password))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Şifre gereklidir.");
        }

        var passwordError = ValidatePassword(request.Password);
        if (passwordError is not null)
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                passwordError);
        }

        var displayName = request.DisplayName.Trim();
        if (displayName.Length < 2)
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Ad soyad en az 2 karakter olmalıdır.");
        }

        var email = request.Email.Trim().ToLowerInvariant();
        if (!IsValidEmail(email))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Geçerli bir e-posta girin.");
        }

        string? phone = null;
        if (!string.IsNullOrWhiteSpace(request.Phone))
        {
            phone = NormalizePhone(request.Phone);
            if (phone.Length < 8)
            {
                return FailSession(
                    AuthErrorCodes.InvalidRequest,
                    "InvalidRequest",
                    "Geçerli bir telefon numarası girin.");
            }
        }

        if (await _userRepository.GetByEmailAsync(email, cancellationToken) is not null)
        {
            return FailSession(
                AuthErrorCodes.UserAlreadyExists,
                "UserAlreadyExists",
                "Bu e-posta adresi zaten kayıtlı.");
        }

        if (phone is not null
            && await _userRepository.GetByPhoneAsync(phone, cancellationToken) is not null)
        {
            return FailSession(
                AuthErrorCodes.UserAlreadyExists,
                "UserAlreadyExists",
                "Bu telefon numarası zaten kayıtlı.");
        }

        var now = DateTime.UtcNow;
        var user = new User
        {
            Id = Guid.NewGuid(),
            DisplayName = displayName,
            Email = email,
            Phone = phone,
            PasswordHash = _passwordHasher.Hash(request.Password),
            CreatedAt = now,
            UpdatedAt = now,
        };

        await _userRepository.AddAsync(user, cancellationToken);

        return await CreateSessionAsync(user, "Kayıt başarılı.", cancellationToken);
    }

    public async Task<AuthServiceResponse<UserProfileEntity>> GetMeAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
        {
            return AuthServiceResponse<UserProfileEntity>.Fail(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "Kullanıcı bulunamadı.");
        }

        var profile = new UserProfileEntity
        {
            UserId = user.Id.ToString(),
            DisplayName = user.DisplayName,
            Email = user.Email,
            Phone = user.Phone,
            OnboardingCompleted = user.OnboardingCompleted,
            CreatedAt = user.CreatedAt,
        };

        return AuthServiceResponse<UserProfileEntity>.Ok(profile, "Profil bilgisi alındı.");
    }

    public async Task<AuthServiceResponse<object?>> ForgotPasswordAsync(
        ForgotPasswordRequest request,
        CancellationToken cancellationToken = default)
    {
        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            var email = request.Email.Trim().ToLowerInvariant();
            var user = await _userRepository.GetByEmailAsync(email, cancellationToken);
            if (user is null)
            {
                return AuthServiceResponse<object?>.Fail(
                    AuthErrorCodes.UserNotFound,
                    "UserNotFound",
                    "Bu e-posta ile kayıtlı kullanıcı bulunamadı.");
            }

            return await SendResetOtpInternalAsync(BuildResetEmailOtpKey(email), email, "email", cancellationToken);
        }

        if (!string.IsNullOrWhiteSpace(request.Phone))
        {
            var phone = NormalizePhone(request.Phone);
            var user = await _userRepository.GetByPhoneAsync(phone, cancellationToken);
            if (user is null)
            {
                return AuthServiceResponse<object?>.Fail(
                    AuthErrorCodes.UserNotFound,
                    "UserNotFound",
                    "Bu telefon ile kayıtlı kullanıcı bulunamadı.");
            }

            return await SendResetOtpInternalAsync(BuildResetPhoneOtpKey(phone), phone, "phone", cancellationToken);
        }

        return AuthServiceResponse<object?>.Fail(
            AuthErrorCodes.InvalidRequest,
            "InvalidRequest",
            "E-posta veya telefon gereklidir.");
    }

    public async Task<AuthServiceResponse<AuthSessionEntity>> ResetPasswordAsync(
        ResetPasswordRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.OtpCode))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Doğrulama kodu gereklidir.");
        }

        if (string.IsNullOrWhiteSpace(request.NewPassword))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Yeni şifre gereklidir.");
        }

        var passwordError = ValidatePassword(request.NewPassword);
        if (passwordError is not null)
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                passwordError);
        }

        User? user;
        string otpKey;

        if (!string.IsNullOrWhiteSpace(request.Email))
        {
            var email = request.Email.Trim().ToLowerInvariant();
            otpKey = BuildResetEmailOtpKey(email);
            user = await _userRepository.GetByEmailAsync(email, cancellationToken);
        }
        else if (!string.IsNullOrWhiteSpace(request.Phone))
        {
            var phone = NormalizePhone(request.Phone);
            otpKey = BuildResetPhoneOtpKey(phone);
            user = await _userRepository.GetByPhoneAsync(phone, cancellationToken);
        }
        else
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "E-posta veya telefon gereklidir.");
        }

        if (user is null)
        {
            return FailSession(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "Kullanıcı bulunamadı.");
        }

        if (!await _authTokenStore.ValidateOtpAsync(otpKey, request.OtpCode, cancellationToken))
        {
            return FailSession(
                AuthErrorCodes.InvalidOtp,
                "InvalidOtp",
                "Doğrulama kodu geçersiz veya süresi dolmuş.");
        }

        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        user.UpdatedAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user, cancellationToken);

        return await CreateSessionAsync(user, "Şifre güncellendi.", cancellationToken);
    }

    public async Task<AuthServiceResponse<UserProfileEntity>> CompleteOnboardingAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
        {
            return AuthServiceResponse<UserProfileEntity>.Fail(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "Kullanıcı bulunamadı.");
        }

        user.OnboardingCompleted = true;
        user.UpdatedAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user, cancellationToken);

        var profile = new UserProfileEntity
        {
            UserId = user.Id.ToString(),
            DisplayName = user.DisplayName,
            Email = user.Email,
            Phone = user.Phone,
            OnboardingCompleted = user.OnboardingCompleted,
            CreatedAt = user.CreatedAt,
        };

        return AuthServiceResponse<UserProfileEntity>.Ok(profile, "Onboarding tamamlandı.");
    }

    private async Task<AuthServiceResponse<object?>> SendResetOtpInternalAsync(
        string otpKey,
        string target,
        string channel,
        CancellationToken cancellationToken)
    {
        var code = GenerateOtpCode();
        await _authTokenStore.SaveOtpAsync(otpKey, code, OtpLifetime, cancellationToken);

        if (channel == "email")
        {
            _logger.LogInformation(
                "Password reset OTP sent to email {Email}. Dev code: {Code}",
                target,
                code);
        }
        else
        {
            _logger.LogInformation(
                "Password reset OTP sent to phone {Phone}. Dev code: {Code}",
                target,
                code);
        }

        return AuthServiceResponse<object?>.Ok(
            null,
            "Şifre sıfırlama kodu gönderildi.");
    }

    private bool VerifyPassword(string password, string? passwordHash) =>
        _passwordHasher.Verify(password, passwordHash);

    private static string? ValidatePassword(string password)
    {
        if (password.Length < MinPasswordLength)
        {
            return $"Şifre en az {MinPasswordLength} karakter olmalıdır.";
        }

        return null;
    }

    private async Task<AuthServiceResponse<object?>> SendPhoneOtpInternalAsync(
        string phone,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(phone))
        {
            return AuthServiceResponse<object?>.Fail(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Phone is required.");
        }

        var normalized = NormalizePhone(phone);
        var code = GenerateOtpCode();
        await _authTokenStore.SaveOtpAsync(
            BuildPhoneOtpKey(normalized),
            code,
            OtpLifetime,
            cancellationToken);

        _logger.LogInformation("OTP sent to phone {Phone}. Dev code: {Code}", normalized, code);

        return AuthServiceResponse<object?>.Ok(
            null,
            "OTP sent successfully.");
    }

    private async Task<AuthServiceResponse<object?>> SendEmailOtpInternalAsync(
        string email,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return AuthServiceResponse<object?>.Fail(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Email is required.");
        }

        var normalized = email.Trim().ToLowerInvariant();
        var code = GenerateOtpCode();
        await _authTokenStore.SaveOtpAsync(
            BuildEmailOtpKey(normalized),
            code,
            OtpLifetime,
            cancellationToken);

        _logger.LogInformation("OTP sent to email {Email}. Dev code: {Code}", normalized, code);

        return AuthServiceResponse<object?>.Ok(
            null,
            "OTP sent successfully.");
    }

    private async Task<AuthServiceResponse<AuthSessionEntity>> CreateSessionAsync(
        User user,
        string message,
        CancellationToken cancellationToken)
    {
        var accessToken = _jwtTokenService.CreateAccessToken(user);
        var refreshToken = _jwtTokenService.CreateRefreshToken();
        var refreshExpires = DateTime.UtcNow.AddDays(_jwtOptions.RefreshTokenDays);

        await _authTokenStore.SaveRefreshTokenAsync(
            user.Id,
            refreshToken,
            refreshExpires,
            cancellationToken);

        var entity = new AuthSessionEntity
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            UserId = user.Id.ToString(),
            ExpiresIn = _jwtOptions.AccessTokenMinutes * 60,
            Email = user.Email,
            Phone = user.Phone,
            DisplayName = user.DisplayName,
        };

        return AuthServiceResponse<AuthSessionEntity>.Ok(entity, message);
    }

    private static AuthServiceResponse<AuthSessionEntity> FailSession(
        int code,
        string description,
        string message) =>
        AuthServiceResponse<AuthSessionEntity>.Fail(code, description, message);

    private static string GenerateOtpCode() =>
        Random.Shared.Next(100000, 999999).ToString();

    private static string NormalizePhone(string phone) =>
        phone.Trim().Replace(" ", string.Empty);

    private static string BuildPhoneOtpKey(string phone) => $"phone:{phone}";

    private static string BuildEmailOtpKey(string email) => $"email:{email}";

    private static string BuildResetEmailOtpKey(string email) => $"reset:email:{email}";

    private static string BuildResetPhoneOtpKey(string phone) => $"reset:phone:{phone}";

    private static bool IsValidEmail(string email)
    {
        var at = email.IndexOf('@');
        if (at <= 0 || at != email.LastIndexOf('@')) return false;
        var dot = email.LastIndexOf('.');
        return dot > at + 1 && dot < email.Length - 1;
    }
}
