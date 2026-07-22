using System.Text.Json;
using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Cardence.Application.Services;
using Cardence.Domain.Constants;
using Cardence.Domain.Entities;
using Cardence.Domain.Exceptions;
using FluentAssertions;
using Microsoft.Extensions.Options;
using NSubstitute;
using Xunit;

namespace Cardence.Tests.Services;

public sealed class RevenueCatWebhookServiceTests
{
    private const string Token = "test-revenuecat-token";

    private readonly IWalletEntitlementRepository _walletRepository =
        Substitute.For<IWalletEntitlementRepository>();
    private readonly ISubscriptionEventRepository _eventRepository =
        Substitute.For<ISubscriptionEventRepository>();
    private readonly IWalletOwnerPremiumSyncService _ownerPremiumSync =
        Substitute.For<IWalletOwnerPremiumSyncService>();
    private readonly RevenueCatWebhookService _service;
    private readonly Guid _userId = Guid.NewGuid();

    public RevenueCatWebhookServiceTests()
    {
        _service = new RevenueCatWebhookService(
            _walletRepository,
            _eventRepository,
            _ownerPremiumSync,
            Options.Create(new RevenueCatOptions
            {
                WebhookAuthorizationToken = Token,
            }));
    }

    [Fact]
    public async Task ProcessAsync_ThrowsForbidden_WhenTokenIsInvalid()
    {
        var body = WebhookBody("event_1", "INITIAL_PURCHASE");

        var act = () => _service.ProcessAsync(body, "Bearer wrong-token", null);

        await act.Should().ThrowAsync<ForbiddenException>();
    }

    [Fact]
    public async Task ProcessAsync_UpgradesUser_WhenInitialPurchaseArrives()
    {
        var body = WebhookBody("event_1", "INITIAL_PURCHASE");
        _eventRepository.ExistsAsync("revenuecat", "event_1", Arg.Any<CancellationToken>())
            .Returns(false);

        var result = await _service.ProcessAsync(body, $"Bearer {Token}", null);

        result.Processed.Should().BeTrue();
        result.Tier.Should().Be(WalletConstants.PremiumTier);
        await _walletRepository.Received(1).SetTierAsync(
            _userId,
            WalletConstants.PremiumTier,
            WalletConstants.PremiumMaxCards,
            Arg.Any<CancellationToken>());
        await _ownerPremiumSync.Received(1).SyncForUserAsync(
            _userId,
            WalletConstants.PremiumTier,
            Arg.Any<CancellationToken>());
        await _eventRepository.Received(1).AddAsync(
            Arg.Is<SubscriptionEvent>(e =>
                e.Provider == "revenuecat" &&
                e.ProviderEventId == "event_1" &&
                e.UserId == _userId &&
                e.EventType == "INITIAL_PURCHASE"),
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task ProcessAsync_DowngradesUser_WhenExpirationArrives()
    {
        var body = WebhookBody("event_2", "EXPIRATION");
        _eventRepository.ExistsAsync("revenuecat", "event_2", Arg.Any<CancellationToken>())
            .Returns(false);

        var result = await _service.ProcessAsync(body, null, Token);

        result.Processed.Should().BeTrue();
        result.Tier.Should().Be(WalletConstants.FreeTier);
        await _walletRepository.Received(1).SetTierAsync(
            _userId,
            WalletConstants.FreeTier,
            WalletConstants.FreeMaxCards,
            Arg.Any<CancellationToken>());
        await _ownerPremiumSync.Received(1).SyncForUserAsync(
            _userId,
            WalletConstants.FreeTier,
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task ProcessAsync_DoesNotChangeTier_WhenSubscriberAliasArrives()
    {
        var body = WebhookBody("event_alias", "SUBSCRIBER_ALIAS");
        _eventRepository.ExistsAsync("revenuecat", "event_alias", Arg.Any<CancellationToken>())
            .Returns(false);

        var result = await _service.ProcessAsync(body, $"Bearer {Token}", null);

        result.Processed.Should().BeTrue();
        result.Tier.Should().BeEmpty();
        await _walletRepository.DidNotReceiveWithAnyArgs()
            .SetTierAsync(default, default!, default, default);
        await _ownerPremiumSync.DidNotReceiveWithAnyArgs()
            .SyncForUserAsync(default, default!, default);
        await _eventRepository.Received(1).AddAsync(
            Arg.Is<SubscriptionEvent>(e => e.EventType == "SUBSCRIBER_ALIAS"),
            Arg.Any<CancellationToken>());
    }

    [Fact]
    public async Task ProcessAsync_DoesNotDowngrade_WhenCancellationArrives()
    {
        var body = WebhookBody("event_cancel", "CANCELLATION");
        _eventRepository.ExistsAsync("revenuecat", "event_cancel", Arg.Any<CancellationToken>())
            .Returns(false);

        var result = await _service.ProcessAsync(body, $"Bearer {Token}", null);

        result.Processed.Should().BeTrue();
        result.Tier.Should().BeEmpty();
        await _walletRepository.DidNotReceiveWithAnyArgs()
            .SetTierAsync(default, default!, default, default);
    }

    [Fact]
    public async Task ProcessAsync_SkipsDuplicateEvent()
    {
        var body = WebhookBody("event_3", "RENEWAL");
        _eventRepository.ExistsAsync("revenuecat", "event_3", Arg.Any<CancellationToken>())
            .Returns(true);

        var result = await _service.ProcessAsync(body, $"Bearer {Token}", null);

        result.Processed.Should().BeFalse();
        result.Duplicate.Should().BeTrue();
        await _walletRepository.DidNotReceiveWithAnyArgs()
            .SetTierAsync(default, default!, default, default);
        await _eventRepository.DidNotReceiveWithAnyArgs()
            .AddAsync(default!, default);
    }

    private JsonElement WebhookBody(string eventId, string eventType)
    {
        var json = $$"""
        {
          "event": {
            "id": "{{eventId}}",
            "type": "{{eventType}}",
            "app_user_id": "{{_userId}}"
          }
        }
        """;
        return JsonDocument.Parse(json).RootElement.Clone();
    }
}
