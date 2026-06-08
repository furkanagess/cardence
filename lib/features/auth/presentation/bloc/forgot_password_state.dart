import 'package:equatable/equatable.dart';

enum ForgotPasswordStatus { initial, loading, success, failure, otpSent }

enum ForgotPasswordStep { email, reset }

class ForgotPasswordState extends Equatable {
  const ForgotPasswordState({
    this.status = ForgotPasswordStatus.initial,
    this.step = ForgotPasswordStep.email,
    this.pendingEmail,
    this.errorMessage,
  });

  final ForgotPasswordStatus status;
  final ForgotPasswordStep step;
  final String? pendingEmail;
  final String? errorMessage;

  bool get isLoading => status == ForgotPasswordStatus.loading;
  bool get isOtpStep => step == ForgotPasswordStep.reset;

  ForgotPasswordState copyWith({
    ForgotPasswordStatus? status,
    ForgotPasswordStep? step,
    String? pendingEmail,
    String? errorMessage,
    bool clearError = false,
    bool clearPendingEmail = false,
  }) {
    return ForgotPasswordState(
      status: status ?? this.status,
      step: step ?? this.step,
      pendingEmail:
          clearPendingEmail ? null : pendingEmail ?? this.pendingEmail,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, step, pendingEmail, errorMessage];
}
