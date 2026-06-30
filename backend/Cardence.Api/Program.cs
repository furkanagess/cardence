using System.Text;
using Cardence.Api.Health;
using Cardence.Api.Middleware;
using Cardence.Application;
using Cardence.Application.Common;
using Cardence.Application.Options;
using Cardence.Infrastructure;
using Cardence.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.FileProviders;
using Microsoft.OpenApi.Models;
using Serilog;

// Railway injects PORT at runtime. ASPNETCORE_URLS overrides UseUrls(), so map PORT
// before the host is built. Local Docker Compose sets ASPNETCORE_URLS explicitly.
static void AppendAllowedHost(ref string allowedHosts, string host)
{
    if (string.IsNullOrWhiteSpace(host))
    {
        return;
    }

    foreach (var entry in allowedHosts.Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
    {
        if (string.Equals(entry, host, StringComparison.OrdinalIgnoreCase))
        {
            return;
        }
    }

    allowedHosts = string.IsNullOrWhiteSpace(allowedHosts) ? host : $"{allowedHosts};{host}";
}

const string railwayHealthcheckHost = "healthcheck.railway.app";
const string railwayAppWildcard = "*.up.railway.app";
var railwayPort = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrWhiteSpace(railwayPort))
{
    Environment.SetEnvironmentVariable("ASPNETCORE_URLS", $"http://+:{railwayPort}");

    var allowedHosts = Environment.GetEnvironmentVariable("AllowedHosts");
    if (string.IsNullOrWhiteSpace(allowedHosts))
    {
        allowedHosts = "cardenceapi.app;www.cardenceapi.app";
    }

    AppendAllowedHost(ref allowedHosts, railwayHealthcheckHost);
    AppendAllowedHost(ref allowedHosts, railwayAppWildcard);

    var railwayPublicDomain = Environment.GetEnvironmentVariable("RAILWAY_PUBLIC_DOMAIN");
    AppendAllowedHost(ref allowedHosts, railwayPublicDomain);

    Environment.SetEnvironmentVariable("AllowedHosts", allowedHosts);
}

var builder = WebApplication.CreateBuilder(args);

if (builder.Environment.IsDevelopment())
{
    builder.Configuration.AddJsonFile(
        "appsettings.Development.local.json",
        optional: true,
        reloadOnChange: true);
}

builder.Services.Configure<ApiOptions>(builder.Configuration.GetSection(ApiOptions.SectionName));

builder.Services.AddCors(options =>
{
    options.AddPolicy("Cardence", policy =>
    {
        policy
            .WithOrigins(
                "https://cardenceapi.app",
                "https://www.cardenceapi.app")
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders =
        ForwardedHeaders.XForwardedFor |
        ForwardedHeaders.XForwardedProto |
        ForwardedHeaders.XForwardedHost;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

builder.Host.UseSerilog((context, services, configuration) =>
    configuration
        .ReadFrom.Configuration(context.Configuration)
        .ReadFrom.Services(services)
        .Enrich.FromLogContext()
        .WriteTo.Console());

builder.Services.AddApplication();
builder.Services.AddInfrastructure(builder.Configuration, builder.Environment);

var apiOptions = builder.Configuration.GetSection(ApiOptions.SectionName).Get<ApiOptions>()
    ?? new ApiOptions();
var publicBaseUrl = apiOptions.PublicBaseUrl.TrimEnd('/');
var jwtOptions = builder.Configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>()
    ?? new JwtOptions();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtOptions.Issuer,
            ValidAudience = jwtOptions.Audience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.SigningKey)),
            ClockSkew = TimeSpan.FromMinutes(1),
        };

        // API isteklerinde tarayıcı yönlendirmesi yerine 401 JSON döner.
        options.Events = new JwtBearerEvents
        {
            OnChallenge = async context =>
            {
                context.HandleResponse();
                context.Response.StatusCode = StatusCodes.Status401Unauthorized;
                context.Response.ContentType = "application/json";

                var traceId = context.HttpContext.TraceIdentifier;
                var payload = ApiResponse<object?>.Fail(
                    ErrorCodes.Unauthorized,
                    "Yetkilendirme gerekli.",
                    traceId: traceId);

                await context.Response.WriteAsJsonAsync(payload);
            },
        };
    });

builder.Services.AddAuthorization(options =>
{
    options.FallbackPolicy = new AuthorizationPolicyBuilder()
        .RequireAuthenticatedUser()
        .AddAuthenticationSchemes(JwtBearerDefaults.AuthenticationScheme)
        .Build();
});

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new()
    {
        Title = "Cardence API",
        Version = "v1",
        Description = "Cardence dijital kartvizit backend servisi.",
    });

    options.AddServer(new OpenApiServer
    {
        Url = publicBaseUrl,
        Description = "Cardence API",
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header. Example: \"Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer",
                },
            },
            Array.Empty<string>()
        },
    });

    options.TagActionsBy(api =>
    {
        if (api.ActionDescriptor.EndpointMetadata.OfType<TagsAttribute>().FirstOrDefault() is { } tags
            && tags.Tags.Count > 0)
        {
            return [tags.Tags[0]];
        }

        return ["Other"];
    });

    options.OrderActionsBy(description =>
    {
        var order = description.ActionDescriptor.EndpointMetadata
            .OfType<TagsAttribute>()
            .FirstOrDefault()?.Tags.FirstOrDefault() switch
        {
            "Authentication" => "01",
            "BusinessCards" => "02",
            "PublicCards" => "03",
            "Wallet" => "04",
            "EventGroups" => "05",
            "Health" => "99",
            _ => "50",
        };

        return $"{order}_{description.RelativePath}";
    });
});

builder.Services.AddHealthChecks()
    .AddDbContextCheck<CardenceDbContext>(
        name: "postgresql",
        failureStatus: HealthStatus.Unhealthy,
        tags: ["ready", "db"]);

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<CardenceDbContext>();
    var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>()
        .CreateLogger("Cardence.Api.Database");

    try
    {
        if (dbContext.Database.IsRelational())
        {
            await dbContext.Database.MigrateAsync();
            logger.LogInformation("Database migrations applied.");
        }
        else
        {
            await dbContext.Database.EnsureCreatedAsync();
            logger.LogWarning("Using in-memory database.");
        }
    }
    catch (Exception ex)
    {
        var connectionString = app.Configuration.GetConnectionString("Default");
        var looksLocal = DatabaseConnectionStringResolver.LooksLikeLocalDefault(connectionString);

        logger.LogError(
            ex,
            "Database startup failed. ConnectionStrings__Default={ConnectionConfigured}, " +
            "DATABASE_URL set={DatabaseUrlSet}, PGHOST set={PgHostSet}. " +
            "On Railway: add a PostgreSQL service and set ConnectionStrings__Default " +
            "or reference DATABASE_PRIVATE_URL from the Postgres service.",
            !string.IsNullOrWhiteSpace(connectionString),
            !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("DATABASE_URL")),
            !string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable("PGHOST")));

        if (app.Environment.IsProduction() && looksLocal)
        {
            throw new InvalidOperationException(
                "Production startup requires a PostgreSQL connection string. " +
                "Set ConnectionStrings__Default on Railway to the Postgres service URL, " +
                "or add a PostgreSQL database to the Railway project.",
                ex);
        }

        throw;
    }
}

app.UseForwardedHeaders();
app.UseSerilogRequestLogging();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors("Cardence");

// Swagger her ortamda açıktır ve auth middleware'inden ÖNCE çalışır; böylece
// arayüz token olmadan görüntülenebilir. API endpoint'leri ise global
// FallbackPolicy nedeniyle yetki ister; kullanıcı Swagger'daki "Authorize"
// (Bearer token) bölümünden auth sağlayarak çağrı yapar.
app.UseSwagger(options =>
{
    options.PreSerializeFilters.Add((swaggerDoc, _) =>
    {
        swaggerDoc.Servers =
        [
            new OpenApiServer
            {
                Url = publicBaseUrl,
                Description = "Cardence API",
            },
        ];
    });
});
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "Cardence API v1");
    options.RoutePrefix = "swagger";
    options.DocumentTitle = $"Cardence API — {publicBaseUrl}";
});

// Kök adres doğrudan Swagger arayüzüne yönlenir.
app.MapGet("/", () => Results.Redirect("/swagger")).AllowAnonymous();

app.Lifetime.ApplicationStarted.Register(() =>
{
    var logger = app.Services.GetRequiredService<ILoggerFactory>().CreateLogger("Cardence.Api");
    logger.LogInformation("Public API base URL: {PublicBaseUrl}", publicBaseUrl);
    logger.LogInformation("Swagger UI: {SwaggerUrl}/swagger", publicBaseUrl);

    var emailOptions = app.Configuration
        .GetSection(EmailOptions.SectionName)
        .Get<EmailOptions>() ?? new EmailOptions();
    if (emailOptions.IsConfigured)
    {
        logger.LogInformation(
            "Email SMTP configured: {Host}:{Port}, From={FromAddress}",
            emailOptions.SmtpHost,
            emailOptions.SmtpPort,
            emailOptions.FromAddress);
    }
    else if (app.Environment.IsProduction())
    {
        logger.LogWarning(
            "Email SMTP is not configured. Password reset links will be logged only. " +
            "Set Email__SmtpHost, Email__SmtpPassword and related variables on Railway.");
    }
});

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

// /uploads yalnızca kimliği doğrulanmış kullanıcılara açık.
app.Use(async (context, next) =>
{
    if (context.Request.Path.StartsWithSegments("/uploads")
        && !(context.User.Identity?.IsAuthenticated ?? false))
    {
        context.Response.StatusCode = StatusCodes.Status401Unauthorized;
        context.Response.ContentType = "application/json";
        await context.Response.WriteAsJsonAsync(
            ApiResponse<object?>.Fail(
                ErrorCodes.Unauthorized,
                "Yetkilendirme gerekli.",
                traceId: context.TraceIdentifier));
        return;
    }

    await next();
});

var uploadsPath = Path.Combine(app.Environment.ContentRootPath, "uploads");
Directory.CreateDirectory(uploadsPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsPath),
    RequestPath = "/uploads",
});

app.MapControllers();
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = check => check.Tags.Contains("ready"),
    ResponseWriter = HealthCheckResponseWriter.WriteReadyResponse,
}).AllowAnonymous();

app.Run();

public partial class Program;
