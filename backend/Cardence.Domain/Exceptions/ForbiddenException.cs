namespace Cardence.Domain.Exceptions;

public class ForbiddenException : DomainException
{
    public ForbiddenException(string message, string code) : base(message)
    {
        Code = code;
    }

    public string Code { get; }
}
