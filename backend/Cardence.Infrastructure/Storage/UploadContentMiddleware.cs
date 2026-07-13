using Cardence.Application.Common;
using Cardence.Application.Interfaces;
using Cardence.Domain.Constants;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;

namespace Cardence.Infrastructure.Storage;

public sealed class UploadContentMiddleware
{
    private readonly RequestDelegate _next;
    private static readonly Dictionary<string, string> ContentTypes = new(StringComparer.OrdinalIgnoreCase)
    {
        [".jpg"] = "image/jpeg",
        [".jpeg"] = "image/jpeg",
        [".png"] = "image/png",
        [".webp"] = "image/webp",
    };

    public UploadContentMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context, IUploadContentStore contentStore)
    {
        if (!context.Request.Path.StartsWithSegments("/uploads", out var remaining))
        {
            await _next(context);
            return;
        }

        var isAuthenticated = context.User.Identity?.IsAuthenticated ?? false;
        if (!isAuthenticated && !MediaUrlBuilder.IsPublicUploadPath(context.Request.Path.Value))
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

        var relativeKey = remaining.Value?.TrimStart('/');
        if (string.IsNullOrWhiteSpace(relativeKey))
        {
            context.Response.StatusCode = StatusCodes.Status404NotFound;
            return;
        }

        var stream = await contentStore.OpenReadAsync(relativeKey, context.RequestAborted);
        if (stream is null)
        {
            context.Response.StatusCode = StatusCodes.Status404NotFound;
            return;
        }

        await using (stream)
        {
            var extension = Path.GetExtension(relativeKey);
            if (ContentTypes.TryGetValue(extension, out var contentType))
            {
                context.Response.ContentType = contentType;
            }

            var cacheValue = context.Request.Query.ContainsKey("v")
                ? "public,max-age=31536000,immutable"
                : "public,max-age=3600";
            context.Response.Headers.CacheControl = cacheValue;

            await stream.CopyToAsync(context.Response.Body, context.RequestAborted);
        }
    }
}

public static class UploadContentMiddlewareExtensions
{
    public static IApplicationBuilder UseUploadContent(this IApplicationBuilder app)
    {
        return app.UseMiddleware<UploadContentMiddleware>();
    }
}
