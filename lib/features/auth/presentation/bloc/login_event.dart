import 'package:equatable/equatable.dart';

enum AuthScreenMode { login, register }

enum LoginMethod { email, phone }

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginStarted extends LoginEvent {
  const LoginStarted();
}

class AuthScreenModeChanged extends LoginEvent {
  const AuthScreenModeChanged(this.mode);

  final AuthScreenMode mode;

  @override
  List<Object?> get props => [mode];
}

class LoginMethodChanged extends LoginEvent {
  const LoginMethodChanged(this.method);

  final LoginMethod method;

  @override
  List<Object?> get props => [method];
}

class RegisterSubmitted extends LoginEvent {
  const RegisterSubmitted({
    required this.displayName,
    required this.email,
    required this.password,
    this.phone,
  });

  final String displayName;
  final String email;
  final String password;
  final String? phone;

  @override
  List<Object?> get props => [displayName, email, password, phone];
}

class LoginEmailSubmitted extends LoginEvent {
  const LoginEmailSubmitted({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class LoginPhoneSubmitted extends LoginEvent {
  const LoginPhoneSubmitted({
    required this.phone,
    required this.password,
  });

  final String phone;
  final String password;

  @override
  List<Object?> get props => [phone, password];
}
