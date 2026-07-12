using Microsoft.AspNetCore.Http;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Cardence.Api.Swagger;

/// <summary>
/// <see cref="IFormFile"/> parametreleri için multipart/form-data şeması üretir.
/// </summary>
public sealed class FileUploadOperationFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        var fileParameters = context.ApiDescription.ParameterDescriptions
            .Where(parameter =>
                parameter.Type == typeof(IFormFile) ||
                parameter.Type == typeof(IFormFile[]))
            .ToList();

        if (fileParameters.Count == 0)
        {
            return;
        }

        var properties = new Dictionary<string, OpenApiSchema>();
        var required = new HashSet<string>();

        foreach (var parameter in fileParameters)
        {
            if (string.IsNullOrWhiteSpace(parameter.Name))
            {
                continue;
            }

            properties[parameter.Name] = new OpenApiSchema
            {
                Type = "string",
                Format = "binary",
            };
            required.Add(parameter.Name);
        }

        if (properties.Count == 0)
        {
            return;
        }

        operation.RequestBody = new OpenApiRequestBody
        {
            Content = new Dictionary<string, OpenApiMediaType>
            {
                ["multipart/form-data"] = new OpenApiMediaType
                {
                    Schema = new OpenApiSchema
                    {
                        Type = "object",
                        Properties = properties,
                        Required = required,
                    },
                },
            },
        };

        var fileParameterNames = fileParameters
            .Select(parameter => parameter.Name)
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        if (operation.Parameters is { Count: > 0 })
        {
            operation.Parameters = operation.Parameters
                .Where(parameter => !fileParameterNames.Contains(parameter.Name))
                .ToList();
        }
    }
}
