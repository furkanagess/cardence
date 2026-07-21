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

class LoginLinkedInSubmitted extends LoginEvent {
  const LoginLinkedInSubmitted({required this.authorizationCode});

  final String authorizationCode;

  @override
  List<Object?> get props => [authorizationCode];
}

class LoginGoogleSubmitted extends LoginEvent {
  const LoginGoogleSubmitted({required this.idToken});

  final String idToken;

  @override
  List<Object?> get props => [idToken];
}

class LoginAppleSubmitted extends LoginEvent {
  const LoginAppleSubmitted({
    required this.identityToken,
    this.authorizationCode,
    this.givenName,
    this.familyName,
  });

  final String identityToken;
  final String? authorizationCode;
  final String? givenName;
  final String? familyName;

  @override
  List<Object?> get props =>
      [identityToken, authorizationCode, givenName, familyName];
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

// --- OTP (geçici kapalı) ---
// enum PhoneLoginStep { enterPhone, enterOtp }
//
// class LoginPhoneOtpRequested extends LoginEvent {
//   const LoginPhoneOtpRequested({required this.phone});
//   final String phone;
// }
//
// class LoginPhoneOtpVerified extends LoginEvent {
//   const LoginPhoneOtpVerified({required this.phone, required this.otpCode});
//   final String phone;
//   final String otpCode;
// }
//
// class LoginPhoneOtpResendRequested extends LoginEvent {
//   const LoginPhoneOtpResendRequested();
// }
//
// class LoginPhoneStepBack extends LoginEvent {
//   const LoginPhoneStepBack();
// }
