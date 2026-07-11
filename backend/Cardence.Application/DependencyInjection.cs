using System.Reflection;
using Cardence.Application.Interfaces;
using Cardence.Application.Services;
using FluentValidation;
using Microsoft.Extensions.DependencyInjection;

namespace Cardence.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());
        services.AddScoped<IBusinessCardService, BusinessCardService>();
        services.AddScoped<ISavedCardService, SavedCardService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<ISupportService, SupportService>();
        services.AddScoped<IEventGroupService, EventGroupService>();
        services.AddScoped<IPlanPolicyService, PlanPolicyService>();
        services.AddScoped<IWalletOwnerPremiumSyncService, WalletOwnerPremiumSyncService>();
        services.AddScoped<IRevenueCatWebhookService, RevenueCatWebhookService>();
        services.AddScoped<INetworkGraphService, NetworkGraphService>();
        return services;
    }
}
