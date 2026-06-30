import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordLinkRequested extends ForgotPasswordEvent {
  const ForgotPasswordLinkRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordBackToEmail extends ForgotPasswordEvent {
  const ForgotPasswordBackToEmail();
}
