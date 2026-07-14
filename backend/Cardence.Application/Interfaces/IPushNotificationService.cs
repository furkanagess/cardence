using Cardence.Application.DTOs.EventGroups;
using Cardence.Application.DTOs.Notifications;

namespace Cardence.Application.Interfaces;

public interface IPushNotificationService
{
    Task RegisterDeviceTokenAsync(
        RegisterPushTokenRequest request,
        CancellationToken cancellationToken = default);

    Task UnregisterDeviceTokenAsync(
        string token,
        CancellationToken cancellationToken = default);

    Task NotifyEventGroupInvitesAsync(
        string eventGroupName,
        string inviterDisplayName,
        IReadOnlyList<CreatedEventGroupInvite> invites,
        CancellationToken cancellationToken = default);

    Task NotifyCardSavedAsync(
        Guid cardOwnerUserId,
        string cardId,
        string? saverDisplayName,
        CancellationToken cancellationToken = default);

    Task NotifyWalletCardInviteAsync(
        Guid inviteeUserId,
        Guid invitationId,
        string? inviterDisplayName,
        CancellationToken cancellationToken = default);
}
