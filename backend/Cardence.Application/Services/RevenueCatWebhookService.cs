using System.Text.Json;
using Cardence.Application.Common;
using Cardence.Application.DTOs.Subscriptions;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using Microsoft.Extensions.Options;

namespace Cardence.Application.Services;

public sealed class RevenueCatWebhookService : IRevenueCatWebhookService
{
    private const string Provider = "revenuecat";

    private readonly IWalletEntitlementRepository _walletRepository;
    private readonly ISubscriptionEventRepository _eventRepository;
    private readonly IWalletOwnerPremiumSyncService _ownerPremiumSync;
    private readonly RevenueCatOptions _options;

    public RevenueCatWebhookService(
        IWalletEntitlementRepository walletRepository,
        ISubscriptionEventRepository eventRepository,
        IWalletOwnerPremiumSyncService ownerPremiumSync,
        IOptions<RevenueCatOptions> options)
    {
        _walletRepository = walletRepository;
        _eventRepository = eventRepository;
        _ownerPremiumSync = ownerPremiumSync;
        _options = options.Value;
    }

    public async Task<RevenueCatWebhookResultDto> ProcessAsync(
        JsonElement body,
        string? authorizationHeader,
        string? revenueCatAuthHeader,
        CancellationToken cancellationToken = default)
    {
        EnsureAuthorized(authorizationHeader, revenueCatAuthHeader);

        var eventElement = TryGetProperty(body, "event", "Event") ?? body;
        var providerEventId = ReadRequiredString(eventElement, "id", "Id", "event_id", "eventId");
        var eventType = ReadRequiredString(eventElement, "type", "Type", "event_type", "eventType");
        var appUserId = ReadRequiredString(
            eventElement,
            "app_user_id",
            "appUserId",
            "AppUserId");

        if (!Guid.TryParse(appUserId, out var userId))
        {
            throw new ForbiddenException(
                "RevenueCat app_user_id does not match a Cardence user id.",
                ErrorCodes.Forbidden);
        }

        if (await _eventRepository.ExistsAsync(Provider, providerEventId, cancellationToken))
        {
            return new RevenueCatWebhookResultDto
            {
                Processed = false,
                Duplicate = true,
                EventType = eventType,
            };
        }

        // null = tier dokunma (SUBSCRIBER_ALIAS, CANCELLATION, bilinmeyen event…).
        // Aksi halde logIn alias / iptal (süre bitmeden) premium'u free'ye çekip
        // /Me'de premium=false bırakıyordu.
        var tier = ResolveTier(eventType);
        if (tier is not null)
        {
            var maxCards = tier == WalletConstants.PremiumTier
                ? WalletConstants.PremiumMaxCards
                : WalletConstants.FreeMaxCards;

            await _walletRepository.SetTierAsync(userId, tier, maxCards, cancellationToken);
            await _ownerPremiumSync.SyncForUserAsync(userId, tier, cancellationToken);
        }

        await _eventRepository.AddAsync(
            new SubscriptionEvent
            {
                Id = Guid.NewGuid(),
                Provider = Provider,
                ProviderEventId = providerEventId,
                UserId = userId,
                EventType = eventType,
                PayloadJson = body.GetRawText(),
                ProcessedAt = DateTime.UtcNow,
            },
            cancellationToken);

        return new RevenueCatWebhookResultDto
        {
            Processed = true,
            Duplicate = false,
            Tier = tier ?? string.Empty,
            EventType = eventType,
        };
    }

    private void EnsureAuthorized(string? authorizationHeader, string? revenueCatAuthHeader)
    {
        if (string.IsNullOrWhiteSpace(_options.WebhookAuthorizationToken))
        {
            throw new ForbiddenException(
                "RevenueCat webhook authorization token is not configured.",
                ErrorCodes.Forbidden);
        }

        var bearer = authorizationHeader?.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase) == true
            ? authorizationHeader["Bearer ".Length..].Trim()
            : authorizationHeader?.Trim();
        var provided = !string.IsNullOrWhiteSpace(revenueCatAuthHeader)
            ? revenueCatAuthHeader.Trim()
            : bearer;

        if (!string.Equals(
                provided,
                _options.WebhookAuthorizationToken,
                StringComparison.Ordinal))
        {
            throw new ForbiddenException(
                "RevenueCat webhook authorization failed.",
                ErrorCodes.Forbidden);
        }
    }

    /// <summary>
    /// Premium veren / geri alan event'ler. null = mevcut wallet tier'ına dokunma.
    /// </summary>
    private static string? ResolveTier(string eventType)
    {
        var normalized = eventType.Trim().ToUpperInvariant();
        return normalized switch
        {
            "INITIAL_PURCHASE" or
            "RENEWAL" or
            "UNCANCELLATION" or
            "PRODUCT_CHANGE" or
            "TRANSFER" or
            "NON_RENEWING_PURCHASE" or
            "TEMPORARY_ENTITLEMENT_GRANT" or
            "SUBSCRIPTION_EXTENDED" => WalletConstants.PremiumTier,
            // CANCELLATION = yenileme iptali; entitlement EXPIRATION'a kadar aktif kalır.
            "EXPIRATION" or
            "REFUND" => WalletConstants.FreeTier,
            _ => null,
        };
    }

    private static JsonElement? TryGetProperty(JsonElement element, params string[] names)
    {
        if (element.ValueKind != JsonValueKind.Object)
        {
            return null;
        }

        foreach (var name in names)
        {
            if (element.TryGetProperty(name, out var property))
            {
                return property;
            }
        }

        return null;
    }

    private static string ReadRequiredString(JsonElement element, params string[] names)
    {
        var property = TryGetProperty(element, names);
        var value = property?.ValueKind == JsonValueKind.String
            ? property.Value.GetString()?.Trim()
            : null;

        if (string.IsNullOrWhiteSpace(value))
        {
            throw new ForbiddenException(
                $"RevenueCat webhook is missing required field '{names[0]}'.",
                ErrorCodes.InvalidCardPayload);
        }

        return value;
    }
}
