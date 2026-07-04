/// Etkinlik oluşturma API çağrısının sonucu.
sealed class CreateEventGroupSubmitResult {
  const CreateEventGroupSubmitResult();
}

class CreateEventGroupSubmitSuccess extends CreateEventGroupSubmitResult {
  const CreateEventGroupSubmitSuccess({
    required this.successTitle,
    required this.successMessage,
  });

  final String successTitle;
  final String successMessage;
}

class CreateEventGroupSubmitFailure extends CreateEventGroupSubmitResult {
  const CreateEventGroupSubmitFailure({
    required this.title,
    required this.message,
  });

  final String title;
  final String message;
}

class CreateEventGroupSubmitPaywallRequired extends CreateEventGroupSubmitResult {
  const CreateEventGroupSubmitPaywallRequired();
}

/// [CreateEventGroupPage.push] dönüş değeri.
enum CreateEventGroupPageOutcome {
  created,
  paywallRequired,
}
