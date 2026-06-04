import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_card_draft.dart';

class OnboardingState extends Equatable {
  OnboardingState({
    this.currentPageIndex = 0,
    OnboardingCardDraft? draft,
    this.isSaving = false,
  }) : draft = draft ??
            OnboardingCardDraft(
              frontVisibleFields: List<String>.from(
                OnboardingCardDraft.defaultFrontVisibleFields,
              ),
            );

  final int currentPageIndex;
  final OnboardingCardDraft draft;
  final bool isSaving;

  int get stepCount => 7; // welcome, name, contact, professional, social, visible, preview
  bool get isLastPage => currentPageIndex >= stepCount - 1;
  bool get isFirstPage => currentPageIndex <= 0;

  OnboardingState copyWith({
    int? currentPageIndex,
    OnboardingCardDraft? draft,
    bool? isSaving,
  }) {
    return OnboardingState(
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      draft: draft ?? this.draft,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [currentPageIndex, draft, isSaving];
}
