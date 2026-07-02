import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/auth_api_exception.dart';
import '../../../business_cards/domain/usecases/persist_onboarding_card.dart';
import '../../domain/entities/onboarding_card_draft.dart';
import '../onboarding_validation.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit({
    required Future<void> Function() completeOnboarding,
    required this.persistOnboardingCard,
    OnboardingCardDraft? initialDraft,
  })  : _completeOnboarding = completeOnboarding,
        super(OnboardingState(draft: initialDraft));

  final Future<void> Function() _completeOnboarding;
  final PersistOnboardingCard persistOnboardingCard;
  OnboardingCardDraft? _pendingDraft;
  bool _draftEmitScheduled = false;

  void setPage(int index) {
    if (index < 0 || index >= OnboardingState.stepCount) return;
    if (index == state.currentPageIndex) return;
    emit(state.copyWith(currentPageIndex: index, clearError: true));
  }

  /// Metin alanı gibi sık güncellemeler — bir sonraki frame'de birleştirilir.
  void updateDraft(OnboardingCardDraft draft) {
    _scheduleDraftEmit(draft);
  }

  /// Renk/efekt gibi anlık seçimler — gecikme olmadan uygulanır.
  void updateDraftImmediate(OnboardingCardDraft draft) {
    _flushPendingDraft();
    _emitDraftIfChanged(draft);
  }

  void _scheduleDraftEmit(OnboardingCardDraft draft) {
    if (draft == state.draft) return;
    _pendingDraft = draft;
    if (_draftEmitScheduled) return;
    _draftEmitScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _draftEmitScheduled = false;
      if (isClosed) return;
      final next = _pendingDraft;
      _pendingDraft = null;
      if (next == null) return;
      _emitDraftIfChanged(next);
    });
  }

  void _flushPendingDraft() {
    if (!_draftEmitScheduled) return;
    _draftEmitScheduled = false;
    final next = _pendingDraft;
    _pendingDraft = null;
    if (next != null) {
      _emitDraftIfChanged(next);
    }
  }

  void _emitDraftIfChanged(OnboardingCardDraft draft) {
    if (draft == state.draft) return;
    emit(state.copyWith(draft: draft, clearError: true));
  }

  void setPhotoUploading(bool isPhotoUploading) {
    if (state.isPhotoUploading == isPhotoUploading) return;
    emit(state.copyWith(isPhotoUploading: isPhotoUploading));
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
    if (!OnboardingValidation.fieldsAreValid(
      displayName: state.draft.displayName,
      company: state.draft.company,
      title: state.draft.title,
      email: state.draft.email,
    )) return false;
    emit(state.copyWith(isSaving: true, clearError: true));
    try {
      final syncedDraft = await persistOnboardingCard(state.draft);
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
