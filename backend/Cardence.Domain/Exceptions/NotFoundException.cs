namespace Cardence.Domain.Exceptions;

public class NotFoundException : DomainException
{
    public NotFoundException(string resource, string identifier)
        : base($"{resource} not found: {identifier}")
    {
        Resource = resource;
        Identifier = identifier;
    }

    public string Resource { get; }
    public string Identifier { get; }
}
