import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/usecases/forgot_password.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc({
    required ForgotPassword forgotPassword,
  })  : _forgotPassword = forgotPassword,
        super(const ForgotPasswordState()) {
    on<ForgotPasswordLinkRequested>(_onLinkRequested);
    on<ForgotPasswordBackToEmail>(_onBackToEmail);
  }

  final ForgotPassword _forgotPassword;

  Future<void> _onLinkRequested(
    ForgotPasswordLinkRequested event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(state.copyWith(status: ForgotPasswordStatus.loading, clearError: true));
    try {
      await _forgotPassword(email: event.email);
      emit(state.copyWith(
        status: ForgotPasswordStatus.linkSent,
        step: ForgotPasswordStep.linkSent,
        pendingEmail: event.email,
      ));
    } on AuthApiException catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: 'Bağlantı hatası. Lütfen tekrar deneyin.',
      ));
    }
  }

  void _onBackToEmail(
    ForgotPasswordBackToEmail event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(state.copyWith(
      step: ForgotPasswordStep.email,
      status: ForgotPasswordStatus.initial,
      clearError: true,
    ));
  }
}
