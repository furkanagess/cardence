using System.Text.Json;
using Cardence.Application.DTOs.Subscriptions;

namespace Cardence.Application.Interfaces;

public interface IRevenueCatWebhookService
{
    Task<RevenueCatWebhookResultDto> ProcessAsync(
        JsonElement body,
        string? authorizationHeader,
        string? revenueCatAuthHeader,
        CancellationToken cancellationToken = default);
}
