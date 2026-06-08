import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordOtpRequested extends ForgotPasswordEvent {
  const ForgotPasswordOtpRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordResetSubmitted extends ForgotPasswordEvent {
  const ForgotPasswordResetSubmitted({
    required this.email,
    required this.otpCode,
    required this.newPassword,
  });

  final String email;
  final String otpCode;
  final String newPassword;

  @override
  List<Object?> get props => [email, otpCode, newPassword];
}

class ForgotPasswordBackToEmail extends ForgotPasswordEvent {
  const ForgotPasswordBackToEmail();
}
