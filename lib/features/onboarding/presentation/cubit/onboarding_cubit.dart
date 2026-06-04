import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/onboarding_card_draft.dart';
import '../../domain/usecases/complete_onboarding.dart';
import '../../domain/usecases/save_onboarding_draft_card.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required this.completeOnboarding,
    required this.saveOnboardingDraftCard,
  }) : super(OnboardingState());

  final CompleteOnboarding completeOnboarding;
  final SaveOnboardingDraftCard saveOnboardingDraftCard;

  void setPage(int index) {
    if (index < 0 || index >= state.stepCount) return;
    emit(state.copyWith(currentPageIndex: index));
  }

  void updateDraft(OnboardingCardDraft draft) {
    emit(state.copyWith(draft: draft));
  }

  void nextPage() {
    if (state.currentPageIndex < state.stepCount - 1) {
      setPage(state.currentPageIndex + 1);
    }
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      setPage(state.currentPageIndex - 1);
    }
  }

  /// Taslağı kaydeder, onboarding'i tamamlar. Son adımda çağrılır.
  Future<void> finishOnboarding() async {
    emit(state.copyWith(isSaving: true));
    try {
      await saveOnboardingDraftCard(state.draft);
      await completeOnboarding();
    } finally {
      if (!isClosed) emit(state.copyWith(isSaving: false));
    }
  }

  /// Skip ile atla – taslak kaydetmeden sadece onboarding tamamlanır.
  Future<void> skipOnboarding() async {
    emit(state.copyWith(isSaving: true));
    try {
      await completeOnboarding();
    } finally {
      if (!isClosed) emit(state.copyWith(isSaving: false));
    }
  }
}
