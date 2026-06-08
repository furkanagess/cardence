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

  /// welcome, name, professional, contact, optional, preview
  static const int stepCount = 6;

  bool get isLastPage => currentPageIndex >= stepCount - 1;
  bool get isFirstPage => currentPageIndex <= 0;

  /// İleri / tamamla öncesi geçerli mi; hata mesajı döner.
  String? validationErrorForStep(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return null;
      case 1:
        return OnboardingValidation.validateDisplayName(draft.displayName);
      case 2:
        return OnboardingValidation.validateCompany(draft.company) ??
            OnboardingValidation.validateTitle(draft.title);
      case 3:
        return OnboardingValidation.validateEmail(draft.email);
      case 4:
      case 5:
        return null;
      default:
        return null;
    }
  }

  String? get validationErrorForCurrentStep =>
      validationErrorForStep(currentPageIndex);

  /// Mevcut adımda Devam / Tamamla aktif mi.
  bool get canProceedCurrentStep {
    if (isFirstPage) return true;
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
