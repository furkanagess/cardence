import 'package:equatable/equatable.dart';

import 'login_event.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.screenMode = AuthScreenMode.login,
    this.method = LoginMethod.email,
    this.errorMessage,
  });

  final LoginStatus status;
  final AuthScreenMode screenMode;
  final LoginMethod method;
  final String? errorMessage;

  bool get isLoading => status == LoginStatus.loading;
  bool get isRegisterMode => screenMode == AuthScreenMode.register;

  LoginState copyWith({
    LoginStatus? status,
    AuthScreenMode? screenMode,
    LoginMethod? method,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      screenMode: screenMode ?? this.screenMode,
      method: method ?? this.method,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, screenMode, method, errorMessage];
}
