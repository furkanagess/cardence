import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/last_login_credentials.dart';
import '../../domain/usecases/get_last_login_credentials.dart';
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
    required GetLastLoginCredentials getLastLoginCredentials,
  })  : _loginWithEmail = loginWithEmail,
        _loginWithPhone = loginWithPhone,
        _registerUser = registerUser,
        _getLastLoginCredentials = getLastLoginCredentials,
        super(const LoginState()) {
    on<LoginStarted>(_onStarted);
    on<AuthScreenModeChanged>(_onScreenModeChanged);
    on<LoginMethodChanged>(_onMethodChanged);
    on<LoginEmailSubmitted>(_onEmailSubmitted);
    on<LoginPhoneSubmitted>(_onPhoneSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  final LoginWithEmail _loginWithEmail;
  final LoginWithPhone _loginWithPhone;
  final RegisterUser _registerUser;
  final GetLastLoginCredentials _getLastLoginCredentials;

  Future<void> _onStarted(
    LoginStarted event,
    Emitter<LoginState> emit,
  ) async {
    final credentials = await _getLastLoginCredentials();
    if (isClosed) return;

    emit(
      state.copyWith(
        lastEmail: credentials.email,
        lastPhone: credentials.phone,
        method: _methodFromCredentials(credentials),
        credentialsLoaded: true,
      ),
    );
  }

  LoginMethod _methodFromCredentials(LastLoginCredentials credentials) {
    return credentials.lastMethod == LastLoginMethod.phone
        ? LoginMethod.phone
        : LoginMethod.email;
  }

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
