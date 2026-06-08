using System.Text;
using Cardence.Api.Middleware;
using Cardence.Application;
using Cardence.Application.Options;
using Cardence.Infrastructure;
using Cardence.Infrastructure.Persistence;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

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
builder.Services.AddInfrastructure(builder.Configuration);

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
    });

builder.Services.AddAuthorization();
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

builder.Services.AddHealthChecks();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<CardenceDbContext>();
    if (dbContext.Database.IsRelational())
    {
        await dbContext.Database.MigrateAsync();
    }
    else
    {
        await dbContext.Database.EnsureCreatedAsync();
    }
}

app.UseForwardedHeaders();
app.UseSerilogRequestLogging();
app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseCors("Cardence");

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

app.Lifetime.ApplicationStarted.Register(() =>
{
    var logger = app.Services.GetRequiredService<ILoggerFactory>().CreateLogger("Cardence.Api");
    logger.LogInformation("Public API base URL: {PublicBaseUrl}", publicBaseUrl);
    logger.LogInformation("Swagger UI: {SwaggerUrl}/swagger", publicBaseUrl);
});

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHealthChecks("/health/ready");

app.Run();

public partial class Program;
