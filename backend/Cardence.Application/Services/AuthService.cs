using Cardence.Application.Common;
using Cardence.Application.DTOs.Auth;
using Cardence.Application.Interfaces;
using Cardence.Application.Mapping;
using Cardence.Application.Options;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Application.Services;

public sealed class AuthService : IAuthService
{
    private const int MinPasswordLength = 8;
    private static readonly TimeSpan OtpLifetime = TimeSpan.FromMinutes(5);

    private readonly IUserRepository _userRepository;
    private readonly IUserAuthProviderRepository _userAuthProviderRepository;
    private readonly IWalletEntitlementRepository _walletEntitlementRepository;
    private readonly ILinkedInAuthService _linkedInAuthService;
    private readonly IBusinessCardRepository _businessCardRepository;
    private readonly ISavedCardRepository _savedCardRepository;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IAuthTokenStore _authTokenStore;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IProfilePhotoStorage _profilePhotoStorage;
    private readonly JwtOptions _jwtOptions;
    private readonly LinkedInAuthOptions _linkedInAuthOptions;
    private readonly ILogger<AuthService> _logger;

    private static readonly HashSet<string> AllowedPhotoContentTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        "image/jpeg",
        "image/jpg",
        "image/png",
        "image/webp",
    };

    public AuthService(
        IUserRepository userRepository,
        IUserAuthProviderRepository userAuthProviderRepository,
        IWalletEntitlementRepository walletEntitlementRepository,
        ILinkedInAuthService linkedInAuthService,
        IBusinessCardRepository businessCardRepository,
        ISavedCardRepository savedCardRepository,
        IJwtTokenService jwtTokenService,
        IAuthTokenStore authTokenStore,
        IPasswordHasher passwordHasher,
        IProfilePhotoStorage profilePhotoStorage,
        IOptions<JwtOptions> jwtOptions,
        IOptions<LinkedInAuthOptions> linkedInAuthOptions,
        ILogger<AuthService> logger)
    {
        _userRepository = userRepository;
        _userAuthProviderRepository = userAuthProviderRepository;
        _walletEntitlementRepository = walletEntitlementRepository;
        _linkedInAuthService = linkedInAuthService;
        _businessCardRepository = businessCardRepository;
        _savedCardRepository = savedCardRepository;
        _jwtTokenService = jwtTokenService;
        _authTokenStore = authTokenStore;
        _passwordHasher = passwordHasher;
        _profilePhotoStorage = profilePhotoStorage;
        _jwtOptions = jwtOptions.Value;
        _linkedInAuthOptions = linkedInAuthOptions.Value;
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

        var phone = PhoneNormalizer.Normalize(request.Phone);

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
            phone = PhoneNormalizer.Normalize(request.Phone);
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
                "Bu e-posta adresi başka bir hesapta kayıtlı.");
        }

        if (!string.IsNullOrEmpty(phone)
            && await _userRepository.GetByPhoneAsync(phone, cancellationToken) is not null)
        {
            return FailSession(
                AuthErrorCodes.UserAlreadyExists,
                "UserAlreadyExists",
                "Bu telefon numarası başka bir hesapta kayıtlı.");
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

    public async Task<AuthServiceResponse<AuthSessionEntity>> LoginWithLinkedInAsync(
        LoginWithLinkedInRequest request,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.AuthorizationCode))
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "LinkedIn yetkilendirme kodu gereklidir.");
        }

        var redirectUri = ResolveLinkedInRedirectUri(request.RedirectUri);
        if (redirectUri is null)
        {
            return FailSession(
                AuthErrorCodes.InvalidRequest,
                "InvalidRequest",
                "Geçersiz yönlendirme adresi.");
        }

        var linkedInResult = await _linkedInAuthService.ExchangeAuthorizationCodeAsync(
            request.AuthorizationCode.Trim(),
            redirectUri,
            cancellationToken);

        if (!linkedInResult.IsSuccess || linkedInResult.Profile is null)
        {
            return FailSession(
                AuthErrorCodes.InvalidOAuthToken,
                "InvalidOAuthToken",
                linkedInResult.ErrorMessage ?? "LinkedIn oturumu doğrulanamadı.");
        }

        var linkedInProfile = linkedInResult.Profile;

        var existingProvider = await _userAuthProviderRepository.GetByProviderAsync(
            AuthProviderIds.LinkedIn,
            linkedInProfile.Sub,
            cancellationToken);

        if (existingProvider is not null)
        {
            var existingUser = await _userRepository.GetByIdAsync(
                existingProvider.UserId,
                cancellationToken);

            if (existingUser is null)
            {
                return FailSession(
                    AuthErrorCodes.UserNotFound,
                    "UserNotFound",
                    "LinkedIn hesabına bağlı kullanıcı bulunamadı.");
            }

            await ApplyLinkedInProfileUpdatesAsync(existingUser, linkedInProfile, cancellationToken);
            await EnsureLinkedInBusinessCardAsync(existingUser, linkedInProfile, cancellationToken);
            return await CreateSessionAsync(existingUser, "Giriş başarılı.", cancellationToken);
        }

        User? user = null;
        if (!string.IsNullOrWhiteSpace(linkedInProfile.Email))
        {
            user = await _userRepository.GetByEmailAsync(linkedInProfile.Email, cancellationToken);
        }

        if (user is not null)
        {
            await _userAuthProviderRepository.AddAsync(
                new UserAuthProvider
                {
                    ProviderId = AuthProviderIds.LinkedIn,
                    ProviderUserId = linkedInProfile.Sub,
                    UserId = user.Id,
                },
                cancellationToken);

            await ApplyLinkedInProfileUpdatesAsync(user, linkedInProfile, cancellationToken);
            await EnsureLinkedInBusinessCardAsync(user, linkedInProfile, cancellationToken);
            return await CreateSessionAsync(user, "Giriş başarılı.", cancellationToken);
        }

        var now = DateTime.UtcNow;
        user = new User
        {
            Id = Guid.NewGuid(),
            DisplayName = linkedInProfile.DisplayName,
            Email = linkedInProfile.Email,
            PhotoUrl = linkedInProfile.PictureUrl,
            PasswordHash = null,
            CreatedAt = now,
            UpdatedAt = now,
        };

        await _userRepository.AddAsync(user, cancellationToken);
        await _userAuthProviderRepository.AddAsync(
            new UserAuthProvider
            {
                ProviderId = AuthProviderIds.LinkedIn,
                ProviderUserId = linkedInProfile.Sub,
                UserId = user.Id,
            },
            cancellationToken);
        await _walletEntitlementRepository.GetOrCreateAsync(user.Id, cancellationToken);
        await EnsureLinkedInBusinessCardAsync(user, linkedInProfile, cancellationToken);

        return await CreateSessionAsync(user, "Giriş başarılı.", cancellationToken);
    }

    private async Task EnsureLinkedInBusinessCardAsync(
        User user,
        LinkedInUserInfo linkedInProfile,
        CancellationToken cancellationToken)
    {
        var cards = await _businessCardRepository.GetByUserIdAsync(user.Id, cancellationToken);
        if (cards.Count == 0)
        {
            var cardId = await CardIdGenerator.GenerateUniqueAsync(
                (candidate, ct) => _businessCardRepository.CardIdExistsAsync(candidate, cancellationToken: ct),
                cancellationToken);

            var now = DateTime.UtcNow;
            var card = new Card
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                CardId = cardId,
                BackgroundColor = "#1B365D",
                AccentColor = "#FFFFFF",
                CreatedAt = now,
                UpdatedAt = now,
            };
            ApplyLinkedInCardFields(card, linkedInProfile, user);

            await _businessCardRepository.AddAsync(card, cancellationToken);
            return;
        }

        var primaryCard = cards.OrderBy(card => card.CreatedAt).First();
        ApplyLinkedInCardFields(primaryCard, linkedInProfile, user);
        primaryCard.UpdatedAt = DateTime.UtcNow;
        await _businessCardRepository.UpdateAsync(primaryCard, cancellationToken);
    }

    private static void ApplyLinkedInCardFields(
        Card card,
        LinkedInUserInfo linkedInProfile,
        User user)
    {
        if (!string.IsNullOrWhiteSpace(linkedInProfile.DisplayName))
        {
            card.DisplayName = linkedInProfile.DisplayName.Trim();
        }
        else if (string.IsNullOrWhiteSpace(card.DisplayName))
        {
            card.DisplayName = user.DisplayName;
        }

        if (!string.IsNullOrWhiteSpace(linkedInProfile.Email))
        {
            card.Email = linkedInProfile.Email;
        }
        else if (string.IsNullOrWhiteSpace(card.Email))
        {
            card.Email = user.Email;
        }

        if (!string.IsNullOrWhiteSpace(linkedInProfile.PictureUrl))
        {
            card.PhotoUrl = linkedInProfile.PictureUrl.Trim();
        }
        else if (string.IsNullOrWhiteSpace(card.PhotoUrl))
        {
            card.PhotoUrl = user.PhotoUrl;
        }

        if (!string.IsNullOrWhiteSpace(linkedInProfile.ProfileUrl))
        {
            card.Linkedin = linkedInProfile.ProfileUrl.Trim();
        }

        if (!string.IsNullOrWhiteSpace(linkedInProfile.Company))
        {
            card.Company = linkedInProfile.Company.Trim();
        }

        if (!string.IsNullOrWhiteSpace(linkedInProfile.Title))
        {
            card.Title = linkedInProfile.Title.Trim();
        }

        if (!string.IsNullOrWhiteSpace(linkedInProfile.Headline)
            && string.IsNullOrWhiteSpace(card.About))
        {
            card.About = linkedInProfile.Headline.Trim();
        }
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

        var profile = await BuildUserProfileAsync(user, cancellationToken);
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
            var phone = PhoneNormalizer.Normalize(request.Phone);
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
            var phone = PhoneNormalizer.Normalize(request.Phone);
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

        var profile = await BuildUserProfileAsync(user, cancellationToken);
        return AuthServiceResponse<UserProfileEntity>.Ok(profile, "Onboarding tamamlandı.");
    }

    private async Task<UserProfileEntity> BuildUserProfileAsync(
        User user,
        CancellationToken cancellationToken)
    {
        var businessCards = await _businessCardRepository.GetByUserIdAsync(
            user.Id,
            cancellationToken);
        var savedCards = await _savedCardRepository.GetByUserIdAsync(
            user.Id,
            cancellationToken);

        return new UserProfileEntity
        {
            UserId = user.Id.ToString(),
            DisplayName = user.DisplayName,
            Email = user.Email,
            Phone = user.Phone,
            PhotoUrl = user.PhotoUrl,
            OnboardingCompleted = user.OnboardingCompleted,
            CreatedAt = user.CreatedAt,
            BusinessCards = businessCards.Select(c => BusinessCardMapper.ToDto(c)).ToList(),
            SavedCards = savedCards.Select(SavedCardMapper.ToDto).ToList(),
        };
    }

    public async Task<AuthServiceResponse<UserProfileEntity>> UploadProfilePhotoAsync(
        Guid userId,
        Stream photoStream,
        string contentType,
        long contentLength,
        CancellationToken cancellationToken = default)
    {
        if (contentLength <= 0 || contentLength > 5 * 1024 * 1024)
        {
            return AuthServiceResponse<UserProfileEntity>.Fail(
                400,
                "InvalidPhoto",
                "Profil fotoğrafı en fazla 5 MB olabilir.");
        }

        if (!AllowedPhotoContentTypes.Contains(contentType))
        {
            return AuthServiceResponse<UserProfileEntity>.Fail(
                400,
                "InvalidPhoto",
                "Yalnızca JPEG, PNG veya WebP formatları desteklenir.");
        }

        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
        {
            return AuthServiceResponse<UserProfileEntity>.Fail(
                AuthErrorCodes.UserNotFound,
                "UserNotFound",
                "Kullanıcı bulunamadı.");
        }

        var photoUrl = await _profilePhotoStorage.SaveProfilePhotoAsync(
            userId,
            photoStream,
            contentType,
            cancellationToken);

        user.PhotoUrl = photoUrl;
        user.UpdatedAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user, cancellationToken);

        var businessCards = await _businessCardRepository.GetByUserIdAsync(
            userId,
            cancellationToken);
        foreach (var card in businessCards)
        {
            card.PhotoUrl = photoUrl;
            card.UpdatedAt = DateTime.UtcNow;
            await _businessCardRepository.UpdateAsync(card, cancellationToken);
        }

        var profile = await BuildUserProfileAsync(user, cancellationToken);
        return AuthServiceResponse<UserProfileEntity>.Ok(
            profile,
            "Profil fotoğrafı güncellendi.");
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

        var normalized = PhoneNormalizer.Normalize(phone);
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

    private async Task ApplyLinkedInProfileUpdatesAsync(
        User user,
        LinkedInUserInfo linkedInProfile,
        CancellationToken cancellationToken)
    {
        var updated = false;

        if (string.IsNullOrWhiteSpace(user.DisplayName)
            && !string.IsNullOrWhiteSpace(linkedInProfile.DisplayName))
        {
            user.DisplayName = linkedInProfile.DisplayName.Trim();
            updated = true;
        }

        if (string.IsNullOrWhiteSpace(user.PhotoUrl)
            && !string.IsNullOrWhiteSpace(linkedInProfile.PictureUrl))
        {
            user.PhotoUrl = linkedInProfile.PictureUrl.Trim();
            updated = true;
        }

        if (string.IsNullOrWhiteSpace(user.Email)
            && !string.IsNullOrWhiteSpace(linkedInProfile.Email))
        {
            user.Email = linkedInProfile.Email;
            updated = true;
        }

        if (!updated)
        {
            return;
        }

        user.UpdatedAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user, cancellationToken);
    }

    private string? ResolveLinkedInRedirectUri(string? requestedRedirectUri)
    {
        var configuredRedirectUri = _linkedInAuthOptions.RedirectUri?.Trim();
        if (string.IsNullOrWhiteSpace(configuredRedirectUri))
        {
            return string.IsNullOrWhiteSpace(requestedRedirectUri)
                ? null
                : requestedRedirectUri.Trim();
        }

        if (string.IsNullOrWhiteSpace(requestedRedirectUri))
        {
            return configuredRedirectUri;
        }

        return string.Equals(
            requestedRedirectUri.Trim(),
            configuredRedirectUri,
            StringComparison.Ordinal)
            ? configuredRedirectUri
            : null;
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
