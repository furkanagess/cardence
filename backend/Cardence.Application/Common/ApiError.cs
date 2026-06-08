namespace Cardence.Application.Common;

public sealed class ApiError
{
    public required string Code { get; init; }
    public required string Message { get; init; }
    public object? Details { get; init; }
}
