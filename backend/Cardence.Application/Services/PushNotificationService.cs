using Cardence.Application.DTOs.EventGroups;
using Cardence.Application.DTOs.Notifications;
using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using FluentValidation;
using Microsoft.Extensions.Logging;

namespace Cardence.Application.Services;

public sealed class PushNotificationService : IPushNotificationService
{
    private readonly IUserDeviceTokenRepository _deviceTokenRepository;
    private readonly ICurrentUserService _currentUser;
    private readonly IPushNotificationSender _pushSender;
    private readonly IValidator<RegisterPushTokenRequest> _registerValidator;
    private readonly ILogger<PushNotificationService> _logger;

    public PushNotificationService(
        IUserDeviceTokenRepository deviceTokenRepository,
        ICurrentUserService currentUser,
        IPushNotificationSender pushSender,
        IValidator<RegisterPushTokenRequest> registerValidator,
        ILogger<PushNotificationService> logger)
    {
        _deviceTokenRepository = deviceTokenRepository;
        _currentUser = currentUser;
        _pushSender = pushSender;
        _registerValidator = registerValidator;
        _logger = logger;
    }

    public async Task RegisterDeviceTokenAsync(
        RegisterPushTokenRequest request,
        CancellationToken cancellationToken = default)
    {
        await _registerValidator.ValidateAndThrowAsync(request, cancellationToken);

        var userId = _currentUser.GetRequiredUserId();
        var token = request.Token.Trim();
        var platform = request.Platform.Trim().ToLowerInvariant();
        var now = DateTime.UtcNow;

        var existing = await _deviceTokenRepository.GetByUserAndTokenAsync(
            userId,
            token,
            cancellationToken);

        if (existing is not null)
        {
            existing.Platform = platform;
            existing.UpdatedAt = now;
            await _deviceTokenRepository.UpsertAsync(existing, cancellationToken);
            return;
        }

        await _deviceTokenRepository.UpsertAsync(new UserDeviceToken
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Token = token,
            Platform = platform,
            CreatedAt = now,
            UpdatedAt = now,
        }, cancellationToken);
    }

    public async Task UnregisterDeviceTokenAsync(
        string token,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(token))
        {
            return;
        }

        var userId = _currentUser.GetRequiredUserId();
        await _deviceTokenRepository.DeleteByUserAndTokenAsync(
            userId,
            token.Trim(),
            cancellationToken);
    }

    public async Task NotifyEventGroupInvitesAsync(
        string eventGroupName,
        string inviterDisplayName,
        IReadOnlyList<CreatedEventGroupInvite> invites,
        CancellationToken cancellationToken = default)
    {
        if (invites.Count == 0)
        {
            return;
        }

        var grouped = invites
            .GroupBy(invite => invite.InviteeUserId)
            .ToList();

        foreach (var group in grouped)
        {
            var inviteeUserId = group.Key;
            var firstInvite = group.First();
            var title = "Etkinlik daveti";
            var body = $"{inviterDisplayName} sizi \"{eventGroupName}\" etkinliğine davet etti.";

            await SendToUserAsync(
                inviteeUserId,
                title,
                body,
                new Dictionary<string, string>
                {
                    ["type"] = PushNotificationTypes.EventGroupInvite,
                    ["invitationId"] = firstInvite.InvitationId.ToString(),
                    ["eventGroupId"] = firstInvite.EventGroupId.ToString(),
                    ["cardId"] = firstInvite.CardId,
                },
                cancellationToken);
        }
    }

    public async Task NotifyCardSavedAsync(
        Guid cardOwnerUserId,
        string cardId,
        string? saverDisplayName,
        CancellationToken cancellationToken = default)
    {
        var saverName = string.IsNullOrWhiteSpace(saverDisplayName)
            ? "Birisi"
            : saverDisplayName.Trim();
        var title = "Kartınız kaydedildi";
        var body = $"{saverName} kartvizitinizi cüzdanına ekledi.";

        await SendToUserAsync(
            cardOwnerUserId,
            title,
            body,
            new Dictionary<string, string>
            {
                ["type"] = PushNotificationTypes.CardSaved,
                ["cardId"] = cardId,
            },
            cancellationToken);
    }

    public async Task NotifyWalletCardInviteAsync(
        Guid inviteeUserId,
        Guid invitationId,
        string? inviterDisplayName,
        CancellationToken cancellationToken = default)
    {
        var inviterName = string.IsNullOrWhiteSpace(inviterDisplayName)
            ? "Birisi"
            : inviterDisplayName.Trim();
        var title = "Cüzdan daveti";
        var body = $"{inviterName} sizi cüzdanına ekledi. Siz de onu eklemek ister misiniz?";

        await SendToUserAsync(
            inviteeUserId,
            title,
            body,
            new Dictionary<string, string>
            {
                ["type"] = PushNotificationTypes.WalletCardInvite,
                ["invitationId"] = invitationId.ToString(),
            },
            cancellationToken);
    }

    private async Task SendToUserAsync(
        Guid userId,
        string title,
        string body,
        IReadOnlyDictionary<string, string> data,
        CancellationToken cancellationToken)
    {
        try
        {
            var tokens = await _deviceTokenRepository.GetTokensByUserIdAsync(
                userId,
                cancellationToken);
            if (tokens.Count == 0)
            {
                return;
            }

            var result = await _pushSender.SendAsync(
                tokens,
                title,
                body,
                data,
                cancellationToken);

            if (result.InvalidTokens.Count > 0)
            {
                await _deviceTokenRepository.DeleteTokensAsync(
                    result.InvalidTokens,
                    cancellationToken);
            }
        }
        catch (Exception ex)
        {
            _logger.LogWarning(
                ex,
                "Push notification failed for user {UserId}",
                userId);
        }
    }
}
