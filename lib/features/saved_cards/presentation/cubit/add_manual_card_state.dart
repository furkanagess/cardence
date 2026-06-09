import 'package:equatable/equatable.dart';

import '../../domain/entities/manual_saved_card_draft.dart';

class AddManualCardState extends Equatable {
  const AddManualCardState({
    this.draft = const ManualSavedCardDraft(),
    this.isSubmitting = false,
    this.errorMessage,
  });

  final ManualSavedCardDraft draft;
  final bool isSubmitting;
  final String? errorMessage;

  AddManualCardState copyWith({
    ManualSavedCardDraft? draft,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AddManualCardState(
      draft: draft ?? this.draft,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [draft, isSubmitting, errorMessage];
}
