namespace Cardence.Application.Common;

public static class ErrorCodes
{
    public const string ValidationError = "VALIDATION_ERROR";
    public const string InvalidCardPayload = "INVALID_CARD_PAYLOAD";
    public const string Unauthorized = "UNAUTHORIZED";
    public const string Forbidden = "FORBIDDEN";
    public const string WalletLimitReached = "WALLET_LIMIT_REACHED";
    public const string WalletDuplicateCard = "WALLET_DUPLICATE_CARD";
    public const string CardNotFound = "CARD_NOT_FOUND";
    public const string DuplicateCardId = "DUPLICATE_CARD_ID";
    public const string EventGroupNotFound = "EVENT_GROUP_NOT_FOUND";
    public const string DuplicateEventGroupName = "DUPLICATE_EVENT_GROUP_NAME";
    public const string OnboardingIncomplete = "ONBOARDING_INCOMPLETE";
    public const string InternalError = "INTERNAL_ERROR";
}
