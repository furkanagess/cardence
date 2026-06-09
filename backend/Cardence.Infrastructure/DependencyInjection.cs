using Cardence.Application.Interfaces;
using Cardence.Application.Options;
using Cardence.Infrastructure.Auth;
using Cardence.Infrastructure.Health;
using Cardence.Infrastructure.Persistence;
using Cardence.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Cardence.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.Configure<JwtOptions>(configuration.GetSection(JwtOptions.SectionName));
        services.Configure<ApiOptions>(configuration.GetSection(ApiOptions.SectionName));
        services.Configure<MonitoringOptions>(configuration.GetSection(MonitoringOptions.SectionName));

        services.AddDbContext<CardenceDbContext>(options =>
        {
            var useInMemory = configuration.GetValue<bool>("Database:UseInMemory");
            var connectionString = DatabaseConnectionStringResolver.Resolve(configuration);

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
        services.AddScoped<IHealthStatusReader, HealthStatusReader>();

        return services;
    }
}
