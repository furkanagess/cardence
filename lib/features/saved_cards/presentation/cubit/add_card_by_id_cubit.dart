import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/card_id_generator.dart';
import '../../domain/entities/add_saved_card_result.dart';
import '../../domain/entities/saved_card.dart';
import '../../domain/entities/saved_card_origin.dart';
import '../../domain/usecases/add_saved_card.dart';
import 'add_card_by_id_state.dart';

class AddCardByIdCubit extends Cubit<AddCardByIdState> {
  AddCardByIdCubit({
    required AddSavedCard addSavedCard,
  })  : _addSavedCard = addSavedCard,
        super(const AddCardByIdState());

  final AddSavedCard _addSavedCard;

  void clearFormError() {
    if (!state.isForm || state.result == null) return;
    emit(state.copyWith(clearResult: true));
  }

  Future<void> submit(String cardId) async {
    if (state.isSubmitting) return;

    final trimmedId = cardId.trim();
    if (!CardIdGenerator.isValid(trimmedId)) {
      emit(
        state.copyWith(
          phase: AddCardByIdPhase.form,
          result: const AddSavedCardInvalidPayload(''),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        phase: AddCardByIdPhase.submitting,
        clearResult: true,
      ),
    );

    final card = SavedCard(
      cardId: trimmedId,
      origin: SavedCardOrigin.cardence,
      savedAt: DateTime.now().millisecondsSinceEpoch,
    );

    final result = await _addSavedCard(card);
    if (isClosed) return;

    switch (result) {
      case AddSavedCardSuccess():
        emit(
          state.copyWith(
            phase: AddCardByIdPhase.success,
            result: result,
          ),
        );
      case AddSavedCardDuplicate():
      case AddSavedCardInvalidPayload():
        emit(
          state.copyWith(
            phase: AddCardByIdPhase.form,
            result: result,
          ),
        );
      case AddSavedCardLimitReached():
      case AddSavedCardPremiumRequired():
        emit(
          state.copyWith(
            phase: AddCardByIdPhase.failure,
            result: result,
          ),
        );
    }
  }
}
