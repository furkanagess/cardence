import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../../onboarding/presentation/onboarding_validation.dart';
import '../../data/datasources/physical_card_image_store.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/manual_saved_card_draft.dart';
import '../../domain/usecases/add_saved_card.dart';
import 'add_manual_card_state.dart';

class AddManualCardCubit extends Cubit<AddManualCardState> {
  AddManualCardCubit({
    required AddSavedCard addSavedCard,
    required PhysicalCardImageStore imageStore,
    ManualSavedCardDraft? initialDraft,
  })  : _addSavedCard = addSavedCard,
        _imageStore = imageStore,
        super(AddManualCardState(draft: initialDraft ?? const ManualSavedCardDraft()));

  final AddSavedCard _addSavedCard;
  final PhysicalCardImageStore _imageStore;

  void setPage(int index) {
    if (index < 0 || index >= AddManualCardState.stepCount) return;
    if (index == state.currentPageIndex) return;
    emit(state.copyWith(currentPageIndex: index, clearError: true));
  }

  void updateDraft(ManualSavedCardDraft draft) {
    emit(state.copyWith(draft: draft, clearError: true));
  }

  void nextPage() {
    if (state.currentPageIndex < AddManualCardState.stepCount - 1) {
      setPage(state.currentPageIndex + 1);
    }
  }

  void previousPage() {
    if (state.currentPageIndex > 0) {
      setPage(state.currentPageIndex - 1);
    }
  }

  Future<AddSavedCardResult?> submit() async {
    if (state.isSubmitting) return null;

    if (!OnboardingValidation.fieldsAreValid(
      displayName: state.draft.displayName,
      company: state.draft.company,
      title: state.draft.title,
      email: state.draft.email,
    )) {
      emit(
        state.copyWith(
          errorMessage: 'Lütfen zorunlu alanları doldurun.',
        ),
      );
      return null;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    final cardId = CardIdGenerator.generateManualWallet();
    final savedAt = DateTime.now().millisecondsSinceEpoch;

    String? frontPath = state.draft.frontImagePath;
    String? backPath = state.draft.backImagePath;

    try {
      if (frontPath != null) {
        frontPath = await _imageStore.persistForCard(
          cardId: cardId,
          sourcePath: frontPath,
          isFront: true,
        );
      }
      if (backPath != null) {
        backPath = await _imageStore.persistForCard(
          cardId: cardId,
          sourcePath: backPath,
          isFront: false,
        );
      }

      final card = state.draft
          .copyWith(frontImagePath: frontPath, backImagePath: backPath)
          .toSavedCard(cardId: cardId, savedAt: savedAt);

      final result = await _addSavedCard(card);
      if (!isClosed) {
        emit(state.copyWith(isSubmitting: false));
      }
      return result;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Kart kaydedilemedi. Lütfen tekrar deneyin.',
          ),
        );
      }
      return null;
    }
  }
}
