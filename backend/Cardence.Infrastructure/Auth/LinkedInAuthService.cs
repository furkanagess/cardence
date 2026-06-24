using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.Json.Serialization;
using Cardence.Application.DTOs.Auth;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Auth;

public sealed class LinkedInAuthService : ILinkedInAuthService
{
    private const string TokenEndpoint = "https://www.linkedin.com/oauth/v2/accessToken";
    private const string UserInfoEndpoint = "https://api.linkedin.com/v2/userinfo";
    private const string IdentityMeEndpoint = "https://api.linkedin.com/rest/identityMe";
    private const string LinkedInApiVersion = "202510.03";

    private readonly HttpClient _httpClient;
    private readonly LinkedInAuthOptions _options;
    private readonly ILogger<LinkedInAuthService> _logger;

    public LinkedInAuthService(
        HttpClient httpClient,
        IOptions<LinkedInAuthOptions> options,
        ILogger<LinkedInAuthService> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<LinkedInExchangeResult> ExchangeAuthorizationCodeAsync(
        string authorizationCode,
        string redirectUri,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.ClientId)
            || string.IsNullOrWhiteSpace(_options.ClientSecret))
        {
            _logger.LogWarning("LinkedIn OAuth is not configured (missing client id or secret).");
            return LinkedInExchangeResult.Failed(
                "LinkedIn girişi sunucuda yapılandırılmamış. Client Secret kontrol edin.");
        }

        var tokenPayload = new Dictionary<string, string>
        {
            ["grant_type"] = "authorization_code",
            ["code"] = authorizationCode,
            ["redirect_uri"] = redirectUri,
            ["client_id"] = _options.ClientId,
            ["client_secret"] = _options.ClientSecret,
        };

        using var tokenRequest = new HttpRequestMessage(HttpMethod.Post, TokenEndpoint)
        {
            Content = new FormUrlEncodedContent(tokenPayload),
        };

        using var tokenResponse = await _httpClient.SendAsync(tokenRequest, cancellationToken);
        if (!tokenResponse.IsSuccessStatusCode)
        {
            var errorBody = await tokenResponse.Content.ReadAsStringAsync(cancellationToken);
            _logger.LogWarning(
                "LinkedIn token exchange failed with status {StatusCode}: {Body}",
                tokenResponse.StatusCode,
                errorBody);
            return LinkedInExchangeResult.Failed(
                MapLinkedInTokenError(errorBody));
        }

        var tokenJson = await tokenResponse.Content.ReadAsStringAsync(cancellationToken);
        var tokenBody = JsonSerializer.Deserialize<LinkedInTokenResponse>(tokenJson);

        if (string.IsNullOrWhiteSpace(tokenBody?.AccessToken))
        {
            _logger.LogWarning("LinkedIn token exchange returned an empty access token.");
            return LinkedInExchangeResult.Failed("LinkedIn oturumu doğrulanamadı.");
        }

        var accessToken = tokenBody.AccessToken;

        using var userInfoRequest = new HttpRequestMessage(HttpMethod.Get, UserInfoEndpoint);
        userInfoRequest.Headers.Authorization =
            new AuthenticationHeaderValue("Bearer", accessToken);

        using var userInfoResponse = await _httpClient.SendAsync(userInfoRequest, cancellationToken);
        if (!userInfoResponse.IsSuccessStatusCode)
        {
            var errorBody = await userInfoResponse.Content.ReadAsStringAsync(cancellationToken);
            _logger.LogWarning(
                "LinkedIn userinfo request failed with status {StatusCode}: {Body}",
                userInfoResponse.StatusCode,
                errorBody);
            return LinkedInExchangeResult.Failed(
                "LinkedIn profil bilgileri alınamadı. OpenID Connect ürününün etkin olduğundan emin olun.");
        }

        var userInfoJson = await userInfoResponse.Content.ReadAsStringAsync(cancellationToken);
        var profile = JsonSerializer.Deserialize<LinkedInUserInfoResponse>(userInfoJson);

        if (profile is null || string.IsNullOrWhiteSpace(profile.Sub))
        {
            _logger.LogWarning("LinkedIn userinfo response did not include a subject id.");
            return LinkedInExchangeResult.Failed("LinkedIn profil kimliği alınamadı.");
        }

        var identityProfile = await TryFetchIdentityMeAsync(accessToken, cancellationToken);
        var meProfile = await TryFetchMeProfileAsync(accessToken, cancellationToken);

        var title = FirstNonEmpty(identityProfile?.Title, meProfile.Title);
        var company = FirstNonEmpty(identityProfile?.Company, meProfile.Company);
        var headline = FirstNonEmpty(meProfile.Headline, BuildHeadline(title, company));
        var profileUrl = FirstNonEmpty(identityProfile?.ProfileUrl, meProfile.ProfileUrl);
        var pictureUrl = FirstNonEmpty(
            identityProfile?.PictureUrl,
            string.IsNullOrWhiteSpace(profile.Picture) ? null : profile.Picture.Trim(),
            meProfile.PictureUrl);
        var school = identityProfile?.School;
        var about = BuildAboutSummary(
            headline,
            title,
            company,
            school,
            identityProfile?.DegreeName);

        return LinkedInExchangeResult.Succeeded(new LinkedInUserInfo
        {
            Sub = profile.Sub.Trim(),
            Email = NormalizeEmail(
                FirstNonEmpty(identityProfile?.Email, profile.Email)),
            DisplayName = FirstNonEmpty(
                ResolveDisplayName(profile),
                identityProfile?.DisplayName),
            PictureUrl = pictureUrl,
            ProfileUrl = profileUrl,
            Headline = headline,
            Title = title,
            Company = company,
            School = school,
            About = about,
        });
    }

    private async Task<LinkedInIdentityProfile?> TryFetchIdentityMeAsync(
        string accessToken,
        CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(HttpMethod.Get, IdentityMeEndpoint);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        request.Headers.Add("LinkedIn-Version", LinkedInApiVersion);

        using var response = await _httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            var body = await response.Content.ReadAsStringAsync(cancellationToken);
            _logger.LogInformation(
                "LinkedIn identityMe unavailable with status {StatusCode}: {Body}",
                response.StatusCode,
                body);
            return null;
        }

        var json = await response.Content.ReadAsStringAsync(cancellationToken);
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;

        string? profileUrl = null;
        string? email = null;
        string? pictureUrl = null;
        string? displayName = null;

        if (root.TryGetProperty("basicInfo", out var basicInfo))
        {
            profileUrl = ReadStringProperty(basicInfo, "profileUrl");
            email = ReadStringProperty(basicInfo, "primaryEmailAddress");

            var firstName = ReadMultiLocaleString(basicInfo, "firstName");
            var lastName = ReadMultiLocaleString(basicInfo, "lastName");
            displayName = JoinName(firstName, lastName);

            if (basicInfo.TryGetProperty("profilePicture", out var profilePicture)
                && profilePicture.TryGetProperty("croppedImage", out var croppedImage))
            {
                pictureUrl = ReadStringProperty(croppedImage, "downloadUrl");
            }
        }

        string? title = null;
        string? company = null;
        if (root.TryGetProperty("primaryCurrentPosition", out var position))
        {
            title = ReadMultiLocaleString(position, "title");
            company = ReadMultiLocaleString(position, "companyName");
        }

        string? school = null;
        string? degreeName = null;
        if (root.TryGetProperty("mostRecentEducation", out var education))
        {
            school = ReadMultiLocaleString(education, "schoolName");
            degreeName = ReadMultiLocaleString(education, "degreeName");
        }

        return new LinkedInIdentityProfile(
            ProfileUrl: profileUrl,
            Email: email,
            PictureUrl: pictureUrl,
            DisplayName: displayName,
            Title: title,
            Company: company,
            School: FormatSchool(school, degreeName),
            DegreeName: degreeName);
    }

    private async Task<LinkedInMeProfile> TryFetchMeProfileAsync(
        string accessToken,
        CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            "https://api.linkedin.com/v2/me?projection=(vanityName,localizedHeadline)");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        request.Headers.Add("X-Restli-Protocol-Version", "2.0.0");

        using var response = await _httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            return LinkedInMeProfile.Empty;
        }

        var json = await response.Content.ReadAsStringAsync(cancellationToken);
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;

        string? profileUrl = null;
        if (root.TryGetProperty("vanityName", out var vanityElement))
        {
            var vanityName = vanityElement.GetString()?.Trim();
            if (!string.IsNullOrWhiteSpace(vanityName))
            {
                profileUrl = $"https://www.linkedin.com/in/{vanityName}";
            }
        }

        var headline = ReadLocalizedHeadline(root);
        var (title, company) = ParseHeadline(headline);

        return new LinkedInMeProfile(profileUrl, headline, title, company, null);
    }

    private static string? BuildAboutSummary(
        string? headline,
        string? title,
        string? company,
        string? school,
        string? degreeName)
    {
        if (!string.IsNullOrWhiteSpace(headline))
        {
            return headline.Trim();
        }

        var builder = new StringBuilder();

        if (!string.IsNullOrWhiteSpace(title) && !string.IsNullOrWhiteSpace(company))
        {
            builder.Append(title.Trim());
            builder.Append(" @ ");
            builder.Append(company.Trim());
        }
        else if (!string.IsNullOrWhiteSpace(title))
        {
            builder.Append(title.Trim());
        }
        else if (!string.IsNullOrWhiteSpace(company))
        {
            builder.Append(company.Trim());
        }

        var educationLine = FormatSchool(school, degreeName);
        if (!string.IsNullOrWhiteSpace(educationLine))
        {
            if (builder.Length > 0)
            {
                builder.AppendLine();
            }

            builder.Append(educationLine);
        }

        var summary = builder.ToString().Trim();
        return string.IsNullOrWhiteSpace(summary) ? null : summary;
    }

    private static string? FormatSchool(string? school, string? degreeName)
    {
        var schoolName = school?.Trim();
        var degree = degreeName?.Trim();

        if (!string.IsNullOrWhiteSpace(degree) && !string.IsNullOrWhiteSpace(schoolName))
        {
            return $"{degree}, {schoolName}";
        }

        if (!string.IsNullOrWhiteSpace(schoolName))
        {
            return schoolName;
        }

        return string.IsNullOrWhiteSpace(degree) ? null : degree;
    }

    private static string? BuildHeadline(string? title, string? company)
    {
        if (string.IsNullOrWhiteSpace(title))
        {
            return company?.Trim();
        }

        if (string.IsNullOrWhiteSpace(company))
        {
            return title.Trim();
        }

        return $"{title.Trim()} @ {company.Trim()}";
    }

    private static string? ReadMultiLocaleString(JsonElement parent, string propertyName)
    {
        if (!parent.TryGetProperty(propertyName, out var element))
        {
            return null;
        }

        if (element.ValueKind == JsonValueKind.String)
        {
            return element.GetString()?.Trim();
        }

        if (!element.TryGetProperty("localized", out var localized))
        {
            return null;
        }

        if (localized.TryGetProperty("en_US", out var english))
        {
            return english.GetString()?.Trim();
        }

        foreach (var property in localized.EnumerateObject())
        {
            var value = property.Value.GetString()?.Trim();
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }
        }

        return null;
    }

    private static string? ReadStringProperty(JsonElement parent, string propertyName)
    {
        if (!parent.TryGetProperty(propertyName, out var element))
        {
            return null;
        }

        return element.GetString()?.Trim();
    }

    private static string? JoinName(string? firstName, string? lastName)
    {
        var parts = new[] { firstName, lastName }
            .Where(part => !string.IsNullOrWhiteSpace(part))
            .Select(part => part!.Trim());

        var displayName = string.Join(' ', parts);
        return string.IsNullOrWhiteSpace(displayName) ? null : displayName;
    }

    private static string? FirstNonEmpty(params string?[] values)
    {
        foreach (var value in values)
        {
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value.Trim();
            }
        }

        return null;
    }

    private static string MapLinkedInTokenError(string errorBody)
    {
        if (string.IsNullOrWhiteSpace(errorBody))
        {
            return "LinkedIn oturumu doğrulanamadı.";
        }

        try
        {
            using var document = JsonDocument.Parse(errorBody);
            var root = document.RootElement;
            var description = root.TryGetProperty("error_description", out var descriptionElement)
                ? descriptionElement.GetString()
                : null;

            if (!string.IsNullOrWhiteSpace(description))
            {
                var normalized = description.ToLowerInvariant();
                if (normalized.Contains("authorization code not found", StringComparison.Ordinal)
                    || normalized.Contains("authorization code expired", StringComparison.Ordinal)
                    || normalized.Contains("code verifier", StringComparison.Ordinal))
                {
                    return "LinkedIn oturumu süresi doldu veya geçersiz. Lütfen tekrar deneyin.";
                }

                if (normalized.Contains("redirect", StringComparison.Ordinal))
                {
                    return "LinkedIn yönlendirme adresi uyuşmuyor. Developer Portal ayarlarını kontrol edin.";
                }

                if (normalized.Contains("invalid client", StringComparison.Ordinal)
                    || normalized.Contains("client authentication", StringComparison.Ordinal))
                {
                    return "LinkedIn uygulama kimlik bilgileri geçersiz. Client Secret kontrol edin.";
                }
            }
        }
        catch (JsonException)
        {
            // Fall through to generic message.
        }

        return "LinkedIn oturumu doğrulanamadı.";
    }

    private static string? ReadLocalizedHeadline(JsonElement root)
    {
        if (!root.TryGetProperty("localizedHeadline", out var headlineElement))
        {
            return null;
        }

        if (headlineElement.ValueKind == JsonValueKind.String)
        {
            return headlineElement.GetString()?.Trim();
        }

        if (!headlineElement.TryGetProperty("localized", out var localized))
        {
            return null;
        }

        if (localized.TryGetProperty("en_US", out var english))
        {
            return english.GetString()?.Trim();
        }

        foreach (var property in localized.EnumerateObject())
        {
            var value = property.Value.GetString()?.Trim();
            if (!string.IsNullOrWhiteSpace(value))
            {
                return value;
            }
        }

        return null;
    }

    private static (string? Title, string? Company) ParseHeadline(string? headline)
    {
        if (string.IsNullOrWhiteSpace(headline))
        {
            return (null, null);
        }

        var text = headline.Trim();

        foreach (var separator in new[] { " at ", " @ ", " | " })
        {
            var index = text.LastIndexOf(separator, StringComparison.OrdinalIgnoreCase);
            if (index <= 0 || index + separator.Length >= text.Length)
            {
                continue;
            }

            var title = text[..index].Trim();
            var company = text[(index + separator.Length)..].Trim();
            return (
                string.IsNullOrWhiteSpace(title) ? null : title,
                string.IsNullOrWhiteSpace(company) ? null : company);
        }

        return (text, null);
    }

    private sealed record LinkedInIdentityProfile(
        string? ProfileUrl,
        string? Email,
        string? PictureUrl,
        string? DisplayName,
        string? Title,
        string? Company,
        string? School,
        string? DegreeName);

    private sealed record LinkedInMeProfile(
        string? ProfileUrl,
        string? Headline,
        string? Title,
        string? Company,
        string? PictureUrl)
    {
        public static LinkedInMeProfile Empty { get; } = new(null, null, null, null, null);
    }

    private static string? NormalizeEmail(string? email)
    {
        if (string.IsNullOrWhiteSpace(email))
        {
            return null;
        }

        return email.Trim().ToLowerInvariant();
    }

    private static string? ResolveDisplayName(LinkedInUserInfoResponse profile)
    {
        if (!string.IsNullOrWhiteSpace(profile.Name))
        {
            return profile.Name.Trim();
        }

        var parts = new[]
        {
            profile.GivenName?.Trim(),
            profile.FamilyName?.Trim(),
        }.Where(part => !string.IsNullOrWhiteSpace(part));

        var displayName = string.Join(' ', parts);
        return string.IsNullOrWhiteSpace(displayName) ? null : displayName;
    }

    private sealed class LinkedInTokenResponse
    {
        [JsonPropertyName("access_token")]
        public string? AccessToken { get; init; }
    }

    private sealed class LinkedInUserInfoResponse
    {
        [JsonPropertyName("sub")]
        public string? Sub { get; init; }

        [JsonPropertyName("name")]
        public string? Name { get; init; }

        [JsonPropertyName("given_name")]
        public string? GivenName { get; init; }

        [JsonPropertyName("family_name")]
        public string? FamilyName { get; init; }

        [JsonPropertyName("email")]
        public string? Email { get; init; }

        [JsonPropertyName("picture")]
        public string? Picture { get; init; }
    }
}
