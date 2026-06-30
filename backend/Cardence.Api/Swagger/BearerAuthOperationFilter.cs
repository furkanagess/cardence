using Microsoft.AspNetCore.Authorization;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Cardence.Api.Swagger;

/// <summary>
/// Swagger UI'da Bearer auth yalnızca kimlik doğrulama gerektiren endpoint'lere
/// uygulanır. [AllowAnonymous] işaretli aksiyonlar kilit simgesi olmadan listelenir;
/// diğer tüm endpoint'ler (global FallbackPolicy) Authorize ile korunur.
/// </summary>
public sealed class BearerAuthOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        var endpointMetadata = context.ApiDescription.ActionDescriptor.EndpointMetadata;

        if (endpointMetadata.OfType<IAllowAnonymous>().Any())
        {
            operation.Security = [];
            return;
        }

        operation.Security =
        [
            new OpenApiSecurityRequirement
            {
                [
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference
                        {
                            Type = ReferenceType.SecurityScheme,
                            Id = "Bearer",
                        },
                    }
                ] = Array.Empty<string>(),
            },
        ];
    }
}
