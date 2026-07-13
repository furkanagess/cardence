using System.Globalization;
using System.Net.Http.Headers;
using System.Text.Json;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace Cardence.Infrastructure.Subscriptions;

public sealed class RevenueCatEntitlementClient : IRevenueCatEntitlementClient
{
    private readonly HttpClient _httpClient;
    private readonly RevenueCatOptions _options;
    private readonly ILogger<RevenueCatEntitlementClient> _logger;

    public RevenueCatEntitlementClient(
        HttpClient httpClient,
        IOptions<RevenueCatOptions> options,
        ILogger<RevenueCatEntitlementClient> logger)
    {
        _httpClient = httpClient;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<bool?> HasActivePremiumEntitlementAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.SecretApiKey))
        {
            return null;
        }

        var entitlementId = string.IsNullOrWhiteSpace(_options.PremiumEntitlementId)
            ? "cardence-pro"
            : _options.PremiumEntitlementId.Trim();

        try
        {
            using var request = new HttpRequestMessage(
                HttpMethod.Get,
                $"https://api.revenuecat.com/v1/subscribers/{Uri.EscapeDataString(userId.ToString())}");
            request.Headers.Authorization =
                new AuthenticationHeaderValue("Bearer", _options.SecretApiKey);

            using var response = await _httpClient.SendAsync(request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                _logger.LogWarning(
                    "RevenueCat subscriber lookup failed for {UserId}: {StatusCode}",
                    userId,
                    response.StatusCode);
                return null;
            }

            await using var stream = await response.Content.ReadAsStreamAsync(cancellationToken);
            using var document = await JsonDocument.ParseAsync(stream, cancellationToken: cancellationToken);
            return IsEntitlementActive(document.RootElement, entitlementId);
        }
        catch (Exception exception) when (exception is not OperationCanceledException)
        {
            _logger.LogWarning(
                exception,
                "RevenueCat subscriber lookup error for {UserId}",
                userId);
            return null;
        }
    }

    private static bool IsEntitlementActive(JsonElement root, string entitlementId)
    {
        if (!TryGetObject(root, out var subscriber, "subscriber", "Subscriber"))
        {
            return false;
        }

        if (!TryGetObject(subscriber, out var entitlements, "entitlements", "Entitlements"))
        {
            return false;
        }

        if (!TryGetObject(entitlements, out var entitlement, entitlementId))
        {
            return false;
        }

        var now = DateTime.UtcNow;
        if (TryReadUtcDate(entitlement, out var expiresDate, "expires_date", "expiresDate"))
        {
            if (expiresDate <= now &&
                TryReadUtcDate(
                    entitlement,
                    out var graceExpiresDate,
                    "grace_period_expires_date",
                    "gracePeriodExpiresDate") &&
                graceExpiresDate > now)
            {
                return true;
            }

            return expiresDate > now;
        }

        return true;
    }

    private static bool TryGetObject(
        JsonElement parent,
        out JsonElement value,
        params string[] names)
    {
        foreach (var name in names)
        {
            if (parent.ValueKind == JsonValueKind.Object &&
                parent.TryGetProperty(name, out value) &&
                value.ValueKind == JsonValueKind.Object)
            {
                return true;
            }
        }

        value = default;
        return false;
    }

    private static bool TryReadUtcDate(
        JsonElement parent,
        out DateTime value,
        params string[] names)
    {
        foreach (var name in names)
        {
            if (!parent.TryGetProperty(name, out var property) ||
                property.ValueKind != JsonValueKind.String)
            {
                continue;
            }

            var raw = property.GetString();
            if (string.IsNullOrWhiteSpace(raw))
            {
                continue;
            }

            if (DateTime.TryParse(
                    raw,
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.AssumeUniversal | DateTimeStyles.AdjustToUniversal,
                    out value))
            {
                return true;
            }
        }

        value = default;
        return false;
    }
}
