using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Cardence.Infrastructure.Auth;
using Cardence.Infrastructure.Background;
using Cardence.Infrastructure.Email;
using Cardence.Infrastructure.Health;
using Cardence.Infrastructure.Persistence;
using Cardence.Infrastructure.Push;
using Cardence.Infrastructure.Repositories;
using Cardence.Infrastructure.Storage;
using Cardence.Infrastructure.Subscriptions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace Cardence.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration,
        IHostEnvironment? environment = null)
    {
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));
        services.Configure<ApiOptions>(configuration.GetSection(ApiOptions.SectionName));
        services.Configure<MonitoringOptions>(configuration.GetSection(MonitoringOptions.SectionName));
        services.Configure<LinkedInAuthOptions>(configuration.GetSection(LinkedInAuthOptions.SectionName));
        services.Configure<RevenueCatOptions>(configuration.GetSection(RevenueCatOptions.SectionName));
        services.Configure<EmailOptions>(configuration.GetSection(EmailOptions.SectionName));
        services.Configure<PasswordResetOptions>(configuration.GetSection(PasswordResetOptions.SectionName));
        services.Configure<PushNotificationOptions>(configuration.GetSection(PushNotificationOptions.SectionName));

        services.AddHttpClient<ILinkedInAuthService, LinkedInAuthService>();
        services.AddHttpClient<IRevenueCatEntitlementClient, RevenueCatEntitlementClient>(client =>
        {
            client.Timeout = TimeSpan.FromSeconds(15);
        });

        services.AddDbContext<CardenceDbContext>(options =>
        {
            var useInMemory = configuration.GetValue<bool>("Database:UseInMemory");
            var connectionString = DatabaseConnectionStringResolver.Resolve(configuration);
            var isProduction = environment?.IsProduction() == true;

            if (isProduction && (useInMemory || string.IsNullOrWhiteSpace(connectionString)))
            {
                throw new InvalidOperationException(
                    "Production requires a PostgreSQL connection string. " +
                    "Set ConnectionStrings__Default=${{Postgres.DATABASE_URL}} on Railway " +
                    "and Database__UseInMemory=false.");
            }

            if (useInMemory || string.IsNullOrWhiteSpace(connectionString))
            {
                options.UseInMemoryDatabase("CardenceDev");
            }
            else
            {
                options.UseNpgsql(connectionString);
            }
        });

        services.AddHttpContextAccessor();
        services.AddScoped<ICurrentUserService, CurrentUserService>();
        services.AddScoped<IAuthTokenStore, EfAuthTokenStore>();
        services.AddScoped<IJwtTokenService, JwtTokenService>();
        services.AddSingleton<IPasswordHasher, Pbkdf2PasswordHasher>();
        services.AddScoped<IBusinessCardRepository, BusinessCardRepository>();
        services.AddScoped<ISavedCardRepository, SavedCardRepository>();
        services.AddScoped<IWalletEntitlementRepository, WalletEntitlementRepository>();
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<IUserAuthProviderRepository, UserAuthProviderRepository>();
        services.AddScoped<IPasswordResetTokenRepository, PasswordResetTokenRepository>();
        services.AddScoped<SmtpEmailSender>();
        services.AddScoped<LoggingEmailSender>();
        services.AddHttpClient<SendGridApiEmailSender>(client =>
        {
            client.Timeout = TimeSpan.FromSeconds(20);
        });
        services.AddScoped<IEmailSender, EmailSenderRouter>();
        services.AddScoped<ISupportRequestRepository, SupportRequestRepository>();
        services.AddScoped<IEventGroupRepository, EventGroupRepository>();
        services.AddScoped<ISubscriptionEventRepository, SubscriptionEventRepository>();
        services.AddScoped<ICardInteractionRepository, CardInteractionRepository>();
        services.AddScoped<IHealthStatusReader, HealthStatusReader>();
        services.AddScoped<IProfilePhotoStorage, LocalProfilePhotoStorage>();
        services.AddScoped<IEventGroupPhotoStorage, LocalEventGroupPhotoStorage>();
        services.AddScoped<IUserDeviceTokenRepository, UserDeviceTokenRepository>();
        services.AddScoped<LoggingPushNotificationSender>();
        services.AddScoped<FcmPushNotificationSender>();
        services.AddScoped<IPushNotificationSender, PushNotificationSenderRouter>();

        services.AddHostedService<ExpiredEventGroupInvitationCleanupService>();

        return services;
    }
}
