using System.Diagnostics;
using System.Net;
using System.Text.Json;
using Cardence.Application.Common;
using Cardence.Domain.Exceptions;
using FluentValidation;

namespace Cardence.Api.Middleware;

public sealed class ExceptionHandlingMiddleware
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
    };

    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionHandlingMiddleware> _logger;

    public ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var traceId = Activity.Current?.Id ?? context.TraceIdentifier;
        var (statusCode, response) = MapException(exception, traceId);

        if (statusCode >= (int)HttpStatusCode.InternalServerError)
        {
            _logger.LogError(exception, "Unhandled exception. TraceId={TraceId}", traceId);
        }
        else
        {
            _logger.LogWarning(exception, "Handled exception. TraceId={TraceId}", traceId);
        }

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = statusCode;
        await context.Response.WriteAsync(JsonSerializer.Serialize(response, JsonOptions));
    }

    private static (int StatusCode, ApiResponse<object?> Response) MapException(Exception exception, string traceId)
    {
        return exception switch
        {
            ValidationException validation => (
                StatusCodes.Status400BadRequest,
                ApiResponse<object?>.Fail(
                    ErrorCodes.ValidationError,
                    "Validation failed.",
                    validation.Errors.Select(e => new { e.PropertyName, e.ErrorMessage }),
                    traceId)),

            NotFoundException notFound => (
                StatusCodes.Status404NotFound,
                ApiResponse<object?>.Fail(
                    ErrorCodes.CardNotFound,
                    notFound.Message,
                    traceId: traceId)),

            ConflictException conflict => (
                StatusCodes.Status409Conflict,
                ApiResponse<object?>.Fail(
                    conflict.Code,
                    conflict.Message,
                    traceId: traceId)),

            ForbiddenException forbidden => (
                StatusCodes.Status403Forbidden,
                ApiResponse<object?>.Fail(
                    forbidden.Code,
                    forbidden.Message,
                    traceId: traceId)),

            UnauthorizedAccessException => (
                StatusCodes.Status401Unauthorized,
                ApiResponse<object?>.Fail(
                    ErrorCodes.Unauthorized,
                    "Unauthorized.",
                    traceId: traceId)),

            _ => (
                StatusCodes.Status500InternalServerError,
                ApiResponse<object?>.Fail(
                    ErrorCodes.InternalError,
                    "An unexpected error occurred.",
                    traceId: traceId)),
        };
    }
}
