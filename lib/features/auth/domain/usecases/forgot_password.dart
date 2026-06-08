import '../repositories/auth_repository.dart';

class ForgotPassword {
  const ForgotPassword(this._repository);

  final AuthRepository _repository;

  Future<void> call({String? email, String? phone}) =>
      _repository.forgotPassword(email: email, phone: phone);
}
