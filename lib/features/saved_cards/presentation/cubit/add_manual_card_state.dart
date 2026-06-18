import 'package:equatable/equatable.dart';

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

  String? validationErrorForStep(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return OnboardingValidation.validateDisplayName(draft.displayName);
      case 1:
        return OnboardingValidation.validateCompany(draft.company) ??
            OnboardingValidation.validateTitle(draft.title);
      case 2:
        return OnboardingValidation.validateEmail(draft.email);
      case 3:
        return null;
      default:
        return null;
    }
  }

  String? get validationErrorForCurrentStep =>
      validationErrorForStep(currentPageIndex);

  bool get canProceedCurrentStep {
    if (isLastPage) return canFinish;
    return validationErrorForCurrentStep == null;
  }

  bool get canFinish => OnboardingValidation.hasRequiredFields(
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
