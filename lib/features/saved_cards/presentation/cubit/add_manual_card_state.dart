import 'package:equatable/equatable.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../onboarding/presentation/onboarding_validation.dart';
import '../../domain/entities/manual_saved_card_draft.dart';

class AddManualCardState extends Equatable {
  const AddManualCardState({
    this.currentPageIndex = 0,
    this.draft = const ManualSavedCardDraft(),
    this.isSubmitting = false,
    this.errorMessage,
  });

  final int currentPageIndex;
  final ManualSavedCardDraft draft;
  final bool isSubmitting;
  final String? errorMessage;

  /// name, professional, optional, preview
  static const int stepCount = 4;

  bool get isLastPage => currentPageIndex >= stepCount - 1;
  bool get isFirstPage => currentPageIndex <= 0;

  String? validationErrorForStep(AppLocalizations l10n, int stepIndex) {
    switch (stepIndex) {
      case 0:
        return OnboardingValidation.validateDisplayName(l10n, draft.displayName);
      case 1:
        return OnboardingValidation.validateCompany(l10n, draft.company) ??
            OnboardingValidation.validateTitle(l10n, draft.title);
      case 2:
        return OnboardingValidation.validateEmail(l10n, draft.email);
      case 3:
        return null;
      default:
        return null;
    }
  }

  String? validationErrorForCurrentStep(AppLocalizations l10n) =>
      validationErrorForStep(l10n, currentPageIndex);

  bool canProceedCurrentStep(AppLocalizations l10n) {
    if (isLastPage) return canFinish(l10n);
    return validationErrorForCurrentStep(l10n) == null;
  }

  bool canFinish(AppLocalizations l10n) =>
      OnboardingValidation.fieldsAreValid(
        displayName: draft.displayName,
        company: draft.company,
        title: draft.title,
        email: draft.email,
      );

  AddManualCardState copyWith({
    int? currentPageIndex,
    ManualSavedCardDraft? draft,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddManualCardState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      draft: draft ?? this.draft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [currentPageIndex, draft, isSubmitting, errorMessage];
}
