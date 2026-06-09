import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_card_draft.dart';
import '../onboarding_validation.dart';

class OnboardingState extends Equatable {
  OnboardingState({
    this.currentPageIndex = 0,
    OnboardingCardDraft? draft,
    this.isSaving = false,
    this.errorMessage,
  }) : draft = draft ??
            OnboardingCardDraft(
              frontVisibleFields: List<String>.from(
                OnboardingCardDraft.defaultFrontVisibleFields,
              ),
            );

  final int currentPageIndex;
  final OnboardingCardDraft draft;
  final bool isSaving;
  final String? errorMessage;

  /// name, professional, contact, optional, preview + renk
  static const int stepCount = 5;

  bool get isLastPage => currentPageIndex >= stepCount - 1;
  bool get isFirstPage => currentPageIndex <= 0;

  /// İleri / tamamla öncesi geçerli mi; hata mesajı döner.
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
      case 4:
        return null;
      default:
        return null;
    }
  }

  String? get validationErrorForCurrentStep =>
      validationErrorForStep(currentPageIndex);

  /// Mevcut adımda Devam / Tamamla aktif mi.
  bool get canProceedCurrentStep {
    if (isLastPage) return canFinish;
    return validationErrorForCurrentStep == null;
  }

  bool get canFinish =>
      OnboardingValidation.hasRequiredFields(
        displayName: draft.displayName,
        company: draft.company,
        title: draft.title,
        email: draft.email,
      );

  OnboardingState copyWith({
    int? currentPageIndex,
    OnboardingCardDraft? draft,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      draft: draft ?? this.draft,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [currentPageIndex, draft, isSaving, errorMessage];
}
