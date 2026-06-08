namespace Cardence.Domain.Exceptions;

public class ConflictException : DomainException
{
    public ConflictException(string message, string code) : base(message)
    {
        Code = code;
    }

    public string Code { get; }
}
