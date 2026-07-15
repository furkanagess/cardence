import 'package:equatable/equatable.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../onboarding_validation.dart';

class OnboardingState extends Equatable {
  OnboardingState({
    this.currentPageIndex = 0,
    OnboardingCardDraft? draft,
    this.isSaving = false,
    this.isPhotoUploading = false,
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
  final bool isPhotoUploading;
  final String? errorMessage;

  /// name, professional, photo, optional, preview
  static const int stepCount = 5;

  bool get isLastPage => currentPageIndex >= stepCount - 1;
  bool get isFirstPage => currentPageIndex <= 0;

  /// İleri / tamamla öncesi geçerli mi; hata mesajı döner.
  String? validationErrorForStep(AppLocalizations l10n, int stepIndex) {
    switch (stepIndex) {
      case 0:
        return OnboardingValidation.validateDisplayName(l10n, draft.displayName);
      case 1:
        return OnboardingValidation.validateCompany(l10n, draft.company) ??
            OnboardingValidation.validateTitle(l10n, draft.title);
      case 2:
        return null;
      case 3:
        return null;
      case 4:
        return null;
      default:
        return null;
    }
  }

  String? validationErrorForCurrentStep(AppLocalizations l10n) =>
      validationErrorForStep(l10n, currentPageIndex);

  /// Mevcut adımda Devam / Tamamla aktif mi.
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

  OnboardingState copyWith({
    int? currentPageIndex,
    OnboardingCardDraft? draft,
    bool? isSaving,
    bool? isPhotoUploading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OnboardingState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      draft: draft ?? this.draft,
      isSaving: isSaving ?? this.isSaving,
      isPhotoUploading: isPhotoUploading ?? this.isPhotoUploading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [currentPageIndex, draft, isSaving, isPhotoUploading, errorMessage];
}
