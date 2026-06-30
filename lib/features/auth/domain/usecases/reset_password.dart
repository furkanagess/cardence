import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class ResetPassword {
  const ResetPassword(this._repository);

  final AuthRepository _repository;

  Future<AuthSession> call({
    String? email,
    String? phone,
    String? otpCode,
    String? resetToken,
    required String newPassword,
  }) =>
      _repository.resetPassword(
        email: email,
        phone: phone,
        otpCode: otpCode,
        resetToken: resetToken,
        newPassword: newPassword,
      );
}
