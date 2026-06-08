using Cardence.Application.Common;
using Xunit;

namespace Cardence.Tests.Common;

public class ApiResponseTests
{
    [Fact]
    public void Ok_SetsSuccessAndData()
    {
        var response = ApiResponse<string>.Ok("test", "trace-1");

        Assert.True(response.Success);
        Assert.Equal("test", response.Data);
        Assert.Null(response.Error);
        Assert.Equal("trace-1", response.TraceId);
    }

    [Fact]
    public void Fail_SetsErrorDetails()
    {
        var response = ApiResponse<object?>.Fail(
            ErrorCodes.ValidationError,
            "Validation failed.",
            new { field = "email" },
            "trace-2");

        Assert.False(response.Success);
        Assert.Null(response.Data);
        Assert.NotNull(response.Error);
        Assert.Equal(ErrorCodes.ValidationError, response.Error!.Code);
        Assert.Equal("trace-2", response.TraceId);
    }
}
