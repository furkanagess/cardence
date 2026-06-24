using System.Net.Http.Headers;
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

    public async Task<LinkedInUserInfo?> ExchangeAuthorizationCodeAsync(
        string authorizationCode,
        string redirectUri,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.ClientId)
            || string.IsNullOrWhiteSpace(_options.ClientSecret))
        {
            _logger.LogWarning("LinkedIn OAuth is not configured (missing client id or secret).");
            return null;
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
            return null;
        }

        var tokenJson = await tokenResponse.Content.ReadAsStringAsync(cancellationToken);
        var tokenBody = JsonSerializer.Deserialize<LinkedInTokenResponse>(tokenJson);

        if (string.IsNullOrWhiteSpace(tokenBody?.AccessToken))
        {
            _logger.LogWarning("LinkedIn token exchange returned an empty access token.");
            return null;
        }

        using var userInfoRequest = new HttpRequestMessage(HttpMethod.Get, UserInfoEndpoint);
        userInfoRequest.Headers.Authorization =
            new AuthenticationHeaderValue("Bearer", tokenBody.AccessToken);

        using var userInfoResponse = await _httpClient.SendAsync(userInfoRequest, cancellationToken);
        if (!userInfoResponse.IsSuccessStatusCode)
        {
            var errorBody = await userInfoResponse.Content.ReadAsStringAsync(cancellationToken);
            _logger.LogWarning(
                "LinkedIn userinfo request failed with status {StatusCode}: {Body}",
                userInfoResponse.StatusCode,
                errorBody);
            return null;
        }

        var userInfoJson = await userInfoResponse.Content.ReadAsStringAsync(cancellationToken);
        var profile = JsonSerializer.Deserialize<LinkedInUserInfoResponse>(userInfoJson);

        if (profile is null || string.IsNullOrWhiteSpace(profile.Sub))
        {
            _logger.LogWarning("LinkedIn userinfo response did not include a subject id.");
            return null;
        }

        var profileUrl = await TryFetchProfileUrlAsync(tokenBody.AccessToken, cancellationToken);

        return new LinkedInUserInfo
        {
            Sub = profile.Sub.Trim(),
            Email = NormalizeEmail(profile.Email),
            DisplayName = ResolveDisplayName(profile),
            PictureUrl = string.IsNullOrWhiteSpace(profile.Picture) ? null : profile.Picture.Trim(),
            ProfileUrl = profileUrl,
        };
    }

    private async Task<string?> TryFetchProfileUrlAsync(
        string accessToken,
        CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            "https://api.linkedin.com/v2/me?projection=(vanityName)");
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);
        request.Headers.Add("X-Restli-Protocol-Version", "2.0.0");

        using var response = await _httpClient.SendAsync(request, cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            return null;
        }

        var json = await response.Content.ReadAsStringAsync(cancellationToken);
        using var document = JsonDocument.Parse(json);
        if (!document.RootElement.TryGetProperty("vanityName", out var vanityElement))
        {
            return null;
        }

        var vanityName = vanityElement.GetString()?.Trim();
        return string.IsNullOrWhiteSpace(vanityName)
            ? null
            : $"https://www.linkedin.com/in/{vanityName}";
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
