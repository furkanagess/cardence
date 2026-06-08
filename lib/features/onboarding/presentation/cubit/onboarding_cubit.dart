import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../../../business_cards/data/mappers/onboarding_draft_mapper.dart';
import '../../../business_cards/domain/usecases/save_business_card.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../../domain/usecases/save_onboarding_draft_card.dart';
import '../onboarding_draft_helper.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required Future<void> Function() completeOnboarding,
    required this.saveOnboardingDraftCard,
    required this.saveBusinessCard,
  })  : _completeOnboarding = completeOnboarding,
        super(OnboardingState());

  final Future<void> Function() _completeOnboarding;
  final SaveOnboardingDraftCard saveOnboardingDraftCard;
  final SaveBusinessCard saveBusinessCard;

  void setPage(int index) {
    if (index < 0 || index >= OnboardingState.stepCount) return;
    emit(state.copyWith(currentPageIndex: index, clearError: true));
  }

  void updateDraft(OnboardingCardDraft draft) {
    emit(state.copyWith(draft: draft, clearError: true));
  }

  void nextPage() {
    if (state.currentPageIndex < OnboardingState.stepCount - 1) {
      setPage(state.currentPageIndex + 1);
    }
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      setPage(state.currentPageIndex - 1);
    }
  }

  /// Taslağı kaydeder, sunucuda kart oluşturur, onboarding'i tamamlar.
  Future<bool> finishOnboarding() async {
    if (!state.canFinish) return false;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final prepared = OnboardingDraftHelper.prepareForSave(state.draft);
      await saveOnboardingDraftCard(prepared);

      final saved = await saveBusinessCard(
        OnboardingDraftMapper.toBusinessCard(prepared),
      );

      final syncedDraft = prepared.copyWith(
        cardId: saved.cardId ?? prepared.cardId,
      );
      await saveOnboardingDraftCard(syncedDraft);
      emit(state.copyWith(draft: syncedDraft));

      await _completeOnboarding();
      return true;
    } on AuthApiException catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'Kart kaydedilemedi. Lütfen tekrar deneyin.',
      ));
      return false;
    } finally {
      if (!isClosed && state.isSaving) {
        emit(state.copyWith(isSaving: false));
      }
    }
  }

  /// Skip ile atla – taslak kaydetmeden sadece onboarding tamamlanır.
  Future<bool> skipOnboarding() async {
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      await _completeOnboarding();
      return true;
    } on AuthApiException catch (e) {
      emit(state.copyWith(isSaving: false, errorMessage: e.message));
      return false;
    } catch (_) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: 'İşlem tamamlanamadı. Lütfen tekrar deneyin.',
      ));
      return false;
    } finally {
      if (!isClosed && state.isSaving) {
        emit(state.copyWith(isSaving: false));
      }
    }
  }
}
