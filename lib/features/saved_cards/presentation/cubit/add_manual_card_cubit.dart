import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/card_id_generator.dart';
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

  void updateDraft(ManualSavedCardDraft draft) {
    emit(state.copyWith(draft: draft, clearError: true));
  }

  Future<AddSavedCardResult?> submit() async {
    if (state.isSubmitting) return null;

    if (!state.draft.hasContactInfo) {
      emit(
        state.copyWith(
          errorMessage: 'En az ad soyad, e-posta veya telefon girin.',
        ),
      );
      return null;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    final cardId = CardIdGenerator.generate();
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
