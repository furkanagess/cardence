import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/login_with_phone.dart';
import '../../domain/usecases/register_user.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required LoginWithEmail loginWithEmail,
    required LoginWithPhone loginWithPhone,
    required RegisterUser registerUser,
  })  : _loginWithEmail = loginWithEmail,
        _loginWithPhone = loginWithPhone,
        _registerUser = registerUser,
        super(const LoginState()) {
    on<AuthScreenModeChanged>(_onScreenModeChanged);
    on<LoginMethodChanged>(_onMethodChanged);
    on<LoginEmailSubmitted>(_onEmailSubmitted);
    on<LoginPhoneSubmitted>(_onPhoneSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final LoginWithEmail _loginWithEmail;
  final LoginWithPhone _loginWithPhone;
  final RegisterUser _registerUser;

  void _onScreenModeChanged(
    AuthScreenModeChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(
      screenMode: event.mode,
      status: LoginStatus.initial,
      clearError: true,
    ));
  }

  void _onMethodChanged(LoginMethodChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      method: event.method,
      status: LoginStatus.initial,
      clearError: true,
    ));
  }

  Future<void> _onEmailSubmitted(
    LoginEmailSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, clearError: true));
    try {
      await _loginWithEmail(email: event.email, password: event.password);
      emit(state.copyWith(status: LoginStatus.success));
    } on AuthApiException catch (e) {
      emit(
          state.copyWith(status: LoginStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Bağlantı hatası. Lütfen tekrar deneyin.',
      ));
    }
  }

  Future<void> _onPhoneSubmitted(
    LoginPhoneSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, clearError: true));
    try {
      await _loginWithPhone(phone: event.phone, password: event.password);
      emit(state.copyWith(status: LoginStatus.success));
    } on AuthApiException catch (e) {
      emit(
          state.copyWith(status: LoginStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Bağlantı hatası. Lütfen tekrar deneyin.',
      ));
    }
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, clearError: true));
    try {
      await _registerUser(
        displayName: event.displayName,
        email: event.email,
        password: event.password,
        phone: event.phone,
      );
      emit(state.copyWith(
        status: LoginStatus.success,
        clearError: true,
      ));
    } on AuthApiException catch (e) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: 'Bağlantı hatası. Lütfen tekrar deneyin.',
      ));
    }
  }
}
