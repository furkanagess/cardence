import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/app_error_keys.dart';
import '../../../../core/network/auth_api_exception.dart';
import '../../domain/entities/support_request.dart';
import '../../domain/entities/support_topic.dart';
import '../../domain/usecases/submit_support_request.dart';
import 'support_state.dart';

class SupportCubit extends Cubit<SupportState> {
  SupportCubit({
    required SubmitSupportRequest submitSupportRequest,
    String? initialEmail,
  })  : _submitSupportRequest = submitSupportRequest,
        super(SupportState(email: initialEmail ?? ''));

  final SubmitSupportRequest _submitSupportRequest;

  void setEmail(String value) {
    emit(state.copyWith(email: value, clearError: true));
  }

  void setTopic(SupportTopic topic) {
    emit(state.copyWith(topic: topic, clearError: true));
  }

  void setMessage(String value) {
    emit(state.copyWith(message: value, clearError: true));
  }

  Future<bool> submit() async {
    if (state.isSubmitting || !state.canSubmit) return false;

    emit(state.copyWith(status: SupportStatus.submitting, clearError: true));

    try {
      await _submitSupportRequest(
        SupportRequest(
          email: state.email,
          topic: state.topic,
          message: state.message,
        ),
      );
      if (!isClosed) {
        emit(state.copyWith(status: SupportStatus.success));
      }
      return true;
    } on AuthApiException catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SupportStatus.failure,
            errorMessage: e.message,
          ),
        );
      }
      return false;
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            status: SupportStatus.failure,
            errorMessage: AppErrorKeys.supportRequestFailedRetry,
          ),
        );
      }
      return false;
    }
  }
}
