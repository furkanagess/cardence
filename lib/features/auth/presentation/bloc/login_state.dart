import 'package:equatable/equatable.dart';

import 'login_event.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.screenMode = AuthScreenMode.login,
    this.method = LoginMethod.email,
    this.lastEmail,
    this.lastPhone,
    this.credentialsLoaded = false,
    this.errorMessage,
  });

  final LoginStatus status;
  final AuthScreenMode screenMode;
  final LoginMethod method;
  final String? lastEmail;
  final String? lastPhone;
  final bool credentialsLoaded;
  final String? errorMessage;

  bool get isLoading => status == LoginStatus.loading;
  bool get isRegisterMode => screenMode == AuthScreenMode.register;

  LoginState copyWith({
    LoginStatus? status,
    AuthScreenMode? screenMode,
    LoginMethod? method,
    String? lastEmail,
    String? lastPhone,
    bool? credentialsLoaded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      screenMode: screenMode ?? this.screenMode,
      method: method ?? this.method,
      lastEmail: lastEmail ?? this.lastEmail,
      lastPhone: lastPhone ?? this.lastPhone,
      credentialsLoaded: credentialsLoaded ?? this.credentialsLoaded,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        screenMode,
        method,
        lastEmail,
        lastPhone,
        credentialsLoaded,
        errorMessage,
      ];
}
