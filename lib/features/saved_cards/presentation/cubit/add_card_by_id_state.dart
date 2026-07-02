import 'package:equatable/equatable.dart';

import '../../domain/entities/add_saved_card_result.dart';

enum AddCardByIdPhase { form, submitting, success, failure }

class AddCardByIdState extends Equatable {
  const AddCardByIdState({
    this.phase = AddCardByIdPhase.form,
    this.result,
  });

  final AddCardByIdPhase phase;
  final AddSavedCardResult? result;

  bool get isForm => phase == AddCardByIdPhase.form;
  bool get isSubmitting => phase == AddCardByIdPhase.submitting;
  bool get isSuccess => phase == AddCardByIdPhase.success;
  bool get isFailure => phase == AddCardByIdPhase.failure;
  bool get isBusy => !isForm;

  AddCardByIdState copyWith({
    AddCardByIdPhase? phase,
    AddSavedCardResult? result,
    bool clearResult = false,
  }) {
    return AddCardByIdState(
      phase: phase ?? this.phase,
      result: clearResult ? null : (result ?? this.result),
    );
  }

  @override
  List<Object?> get props => [phase, result];
}
